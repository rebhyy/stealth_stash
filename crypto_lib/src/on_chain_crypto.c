#include "on_chain_crypto.h"
#include <stdint.h>
#include <stdlib.h>
#include "sc.h"
#include "ge.h"
#include "keccak.h"

VarintResult write_varint(uint32_t value)
{
    // Allocate a buffer big enough for varint (max 5 bytes for uint32_t)
    uint8_t *buffer = (uint8_t *)malloc(5);
    size_t i = 0;

    while (value >= 0x80)
    {
        buffer[i++] = (value & 0x7F) | 0x80;
        value >>= 7;
    }
    buffer[i++] = value & 0x7F;

    VarintResult result = {buffer, i};
    return result;
}

int monero_generate_key_derivation(const unsigned char *pubkey_bytes, const unsigned char *secret_scalar, unsigned char *out_bytes)
{
    ge_p3 point;
    ge_p2 point2;
    ge_p1p1 point3;
    if (ge_frombytes_vartime(&point, pubkey_bytes) != 0)
    {
        return 1;
    }
    ge_scalarmult(&point2, secret_scalar, &point);
    ge_mul8(&point3, &point2);
    ge_p1p1_to_p2(&point2, &point3);
    ge_tobytes(out_bytes, &point2);
    return 0;
}

int monero_derive_public_key(const unsigned char *scalar, const unsigned char *base,
                             unsigned char *out_bytes)
{
    ge_p3 point1;
    ge_p3 point2;
    ge_cached point3;
    ge_p1p1 point4;
    ge_p2 point5;
    if (ge_frombytes_vartime(&point1, base) != 0)
    {
        return 1;
    }
    ge_scalarmult_base(&point2, scalar);
    ge_p3_to_cached(&point3, &point2);
    ge_add(&point4, &point1, &point3);
    ge_p1p1_to_p2(&point5, &point4);
    ge_tobytes(out_bytes, &point5);
    return 0;
}

void keccak_fast_hash(const void *data, size_t length, unsigned char *hash)
{
    cn_fast_hash(data, length, hash);
}

int monero_derive_to_scalar(const uint8_t *derivation, size_t derivation_len, uint32_t out_index, uint8_t *out)
{
    VarintResult varint = write_varint(out_index);
    size_t input_len = derivation_len + varint.length;
    uint8_t *input = (uint8_t *)malloc(input_len);
    memcpy(input, derivation, derivation_len);
    memcpy(input + derivation_len, varint.data, varint.length);
    keccak_fast_hash(input, input_len, out);
    sc_reduce32(out);
    free(varint.data);
    free(input);
    return 0;
}

int monero_derive_output_public_key(
    const uint8_t *derivation,
    uint32_t output_index,
    const uint8_t *spend_pub_key,
    uint8_t *derived_pub_key_out // 32-byte
)
{
    uint8_t scalar[32];
    monero_derive_to_scalar(derivation, 32, output_index, scalar);
    return monero_derive_public_key(scalar, spend_pub_key, derived_pub_key_out);
}

int monero_derive_view_tag(const uint8_t *derivation, size_t derivation_len, uint32_t out_index)
{
    // Serialize output index as varint
    VarintResult varint = write_varint(out_index);
    // Total input = domain + derivation + varint
    size_t input_len = VIEW_TAG_DOMAIN_LEN + derivation_len + varint.length;
    uint8_t *input = (uint8_t *)malloc(input_len);
    memcpy(input, VIEW_TAG_DOMAIN, VIEW_TAG_DOMAIN_LEN);
    memcpy(input + VIEW_TAG_DOMAIN_LEN, derivation, derivation_len);
    memcpy(input + VIEW_TAG_DOMAIN_LEN + derivation_len, varint.data, varint.length);
    uint8_t hash[32];
    keccak_fast_hash(input, input_len, hash);
    free(varint.data);
    free(input);

    return hash[0];
}
int monero_is_account_output(
    const uint8_t *view_secret_key,
    const uint8_t *tx_pub_key,
    int32_t view_tag, // 0 if not available
    uint32_t output_index,
    uint8_t *derivation_out // 32-byte shared secret
)
{
    if (monero_generate_key_derivation(tx_pub_key, view_secret_key, derivation_out) != 0)
    {
        return 1;
    }
    if (view_tag < 0)
    {
        return 0;
    }

    int computed_tag = monero_derive_view_tag(derivation_out, PUBKEY_SIZE, output_index);
    return view_tag == computed_tag ? 0 : 1;

}

void monero_unlock_result_free(MoneroUnlockResult *result)
{
    if (result)
    {
        if (result->items)
        {
            free(result->items);
        }
        free(result);
    }
}
MoneroUnlockResult *monero_unlock_outputs_batch_compact(
    const uint8_t *view_secret_keys,
    const uint8_t *spend_public_keys,
    const uint8_t *out_public_keys,
    const int32_t *spend_index_counts,
    const uint8_t *tx_pub_keys,
    const uint8_t *additional_pub_keys,
    const int32_t *view_tags,
    const int32_t out_count,
    const int32_t acc_count)
{
    MoneroUnlockResult *result = (MoneroUnlockResult *)malloc(sizeof(MoneroUnlockResult));
    result->count = 0;
    result->items = NULL;

    int spend_key_offset = 0;

    for (int acc = 0; acc < acc_count; acc++)
    {
        const uint8_t *view_key = view_secret_keys + acc * PUBKEY_SIZE;
        int spend_key_count = spend_index_counts[acc];
        const uint8_t *spend_keys = spend_public_keys + spend_key_offset * PUBKEY_SIZE;
        spend_key_offset += spend_key_count;

        for (int out = 0; out < out_count; out++)
        {
            const uint8_t *out_key = out_public_keys + out * PUBKEY_SIZE;
            const uint8_t *add_pub_key = additional_pub_keys ? additional_pub_keys + out * PUBKEY_SIZE : NULL;
            int32_t tag = view_tags[out];

            uint8_t derivation[PUBKEY_SIZE];
            uint8_t derived_pk[PUBKEY_SIZE];

            // Try both primary and additional pubkey derivations
            const uint8_t *pubkeys[2] = {tx_pub_keys, add_pub_key};
            for (int p = 0; p < 2; p++)
            {
                if (pubkeys[p] == NULL)
                    continue;

                if (monero_is_account_output(view_key, pubkeys[p], tag, (uint32_t)out, derivation) != 0)
                    continue;

                for (int idx = 0; idx < spend_key_count; idx++)
                {
                    const uint8_t *spend_key = spend_keys + idx * PUBKEY_SIZE;
                    if (monero_derive_output_public_key(derivation, (uint32_t)out, spend_key, derived_pk) != 0)
                        continue;

                    if (memcmp(out_key, derived_pk, PUBKEY_SIZE) == 0)
                    {
                        // Allocate and copy result
                        result->items = realloc(result->items, sizeof(MoneroMatchedOutput) * (result->count + 1));
                        MoneroMatchedOutput *entry = &result->items[result->count++];
                        entry->out_index = out;
                        entry->account_index = acc;
                        entry->address_index = idx;
                        memcpy(entry->derivation, derivation, PUBKEY_SIZE);
                        memcpy(entry->derived_pk, derived_pk, PUBKEY_SIZE);
                    }
                }
            }
        }
    }

    return result;
}
