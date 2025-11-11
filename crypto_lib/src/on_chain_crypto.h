#ifndef ON_CHAIN_CRYPTO_H
#define ON_CHAIN_CRYPTO_H
#include <stdint.h>
#include <string.h>
#define PUBKEY_SIZE 32
// #define VIEW_TAG_DOMAIN_LEN 1
#define VIEW_TAG_DOMAIN_LEN 8
static const uint8_t VIEW_TAG_DOMAIN[] = {
    118, 105, 101, 119, 95, 116, 97, 103};

typedef struct
{
    uint8_t *data;
    int32_t length;
} VarintResult;

typedef struct
{
    int32_t out_index;
    uint8_t derivation[PUBKEY_SIZE];
    uint8_t derived_pk[PUBKEY_SIZE];
    int32_t account_index;
    int32_t address_index;
} MoneroMatchedOutput;

typedef struct
{
    int32_t count;
    MoneroMatchedOutput *items;
} MoneroUnlockResult;

VarintResult write_varint(uint32_t value);

int monero_generate_key_derivation(const unsigned char *pubkey_bytes, const unsigned char *secret_scalar, unsigned char *out_bytes);
int monero_derive_public_key(const unsigned char *scalar, const unsigned char *base,
                      unsigned char *out_bytes);


void keccak_fast_hash(const void *data, size_t length, unsigned char *hash);
int monero_derive_to_scalar(const uint8_t *derivation, size_t derivation_len, uint32_t out_index, uint8_t *out);
int monero_derive_output_public_key(
    const uint8_t *derivation,
    uint32_t output_index,
    const uint8_t *spend_pub_key,
    uint8_t *derived_pub_key_out // 32-byte
);
int monero_derive_view_tag(const uint8_t *derivation, size_t derivation_len, uint32_t out_index);
int monero_is_account_output(
    const uint8_t *view_secret_key,
    const uint8_t *tx_pub_key,
    int32_t view_tag, // 0 if not available
    uint32_t output_index,
    uint8_t *derivation_out // 32-byte shared secret
);
void monero_unlock_result_free(MoneroUnlockResult *result);
MoneroUnlockResult *monero_unlock_outputs_batch_compact(
    const uint8_t *view_secret_keys,
    const uint8_t *spend_public_keys,
    const uint8_t *out_public_keys,
    const int32_t *spend_index_counts,
    const uint8_t *tx_pub_keys,
    const uint8_t *additional_pub_keys,
    const int32_t *view_tags,
    const int32_t out_count,
    const int32_t acc_count);


#endif