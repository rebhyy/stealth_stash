# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project overview

This repository contains **Stealth Stash** (formerly OnChain Wallet), a multi-chain Flutter wallet targeting Android, Windows, macOS, Web, and browser extensions (Chrome/Edge/Brave/Opera/Firefox). It combines:

- A Flutter UI and custom state-management layer (`lib/main.dart`, `lib/future`)  
- A wallet domain layer for network APIs, providers, and chain abstractions (`lib/wallet`)  
- A crypto/keys engine with isolates and platform-bridged implementations (`lib/crypto`)  
- Build tooling and web/extension/WASM glue (`app_builder.dart`, `web*`, `js`, `assets/wasm`, `assets/webview`)

For an end-user feature overview and supported networks, see `README.md`.

## Common commands

All commands below assume the repository root as the working directory.

### Setup

- Install Flutter (version compatible with `sdk: '>=3.6.0 <4.0.0'`).  
- Fetch dependencies:
  - `flutter pub get`

### Running the app during development

Standard Flutter workflows work as expected; examples:

- Run on Windows desktop:  
  `flutter run -d windows`
- Run as a standard web app (debug):  
  `flutter run -d chrome`

The entrypoint is `lib/main.dart`.

### Building via `app_builder.dart`

`app_builder.dart` orchestrates multi-target builds, JS/WASM compilation, and browser-extension packaging. It assumes a valid "wallet context" (checks for `pubspec.yaml`, required asset/js directories, and `name: stealth_stash`).

Typical builds (after `flutter pub get`):

- Web app (release):
  - `dart run app_builder.dart -web`
- Chromium-based browser extension (Chrome/Edge/Brave):
  - `dart run app_builder.dart -chrome`
- Opera extension:
  - `dart run app_builder.dart -opera`
- Firefox extension:
  - `dart run app_builder.dart -firefox`
- Android APK:
  - `dart run app_builder.dart -apk`
- macOS app / DMG (must be run on macOS):
  - `dart run app_builder.dart -macos`

Notes:
- `app_builder.dart` supports additional flags (e.g. `--debug`, `--split-per-abi`, `--no-webview`, `--no-crypto`, `--no-http`, `--no-scripts`, `--out=...`).  
- For details on what each flag does (web vs extension builds, WASM vs JS crypto, webview behavior), consult `app_builder.dart` directly.

### Linting / static analysis

- Run Dart/Flutter analyzer with the repo’s configured lints (`analysis_options.yaml`):  
  `flutter analyze`

The analyzer is configured to use `package:flutter_lints/flutter.yaml` and explicitly ignores `use_build_context_synchronously`.

### Tests

The project includes the Flutter test tooling and the `test` package as dev dependencies.

- Run all tests:  
  `flutter test`
- Run a single test file (example):  
  `flutter test test/widget_test.dart`

### Native libraries (Monero and SQLite3 Multiple Ciphers)

Two native FFI components are managed separately from the Flutter code:

- `crypto_lib/` – Monero output-detection native library (ed25519-based):
  - Build with CMake / platform toolchain to produce `.so` / `.dll` / `.dylib` / `.a` artifacts.
  - Place built artifacts in the platform-specific locations described in `crypto_lib/README.md` (e.g. `android/app/src/main/jniLibs/...`, `macos/Runner/Frameworks/`, `windows/`).
- `sqllite3_multiple_ciphers/` – SQLite3MultipleCiphers database engine:
  - Build from the upstream `SQLite3MultipleCiphers` repository.
  - Place artifacts per `sqllite3_multiple_ciphers/README.md` (similar per-ABI/per-OS folder layout).

These binaries must exist for non-web platforms using the Monero wallet features and encrypted SQLite storage.

## High-level architecture

### Entry point and application bootstrap

- `lib/main.dart`
  - Configures a global `HttpOverrides` (`APPHTTPConfig`) to accept all TLS certificates (important when reasoning about network errors / security implications).  
  - Initializes `PlatformInterface.instance` (from `on_chain_bridge`) and reads persisted `APPSetting` from the embedded database.
  - On desktop platforms, configures the native window (size, bounds) via `PlatformInterface.instance.desktop` before showing the UI.
  - Boots the app with a custom state-management layer: wraps `MaterialApp` in `StateRepository` and a `StateBuilder<WalletProvider>`.
  - Uses `PageRouter.onGenerateRoute` and `PageRouter.home` (`"/"`) as the initial route.

### App-level shared layer (`lib/app`)

This layer exposes reusable, non-UI, non-chain-specific services via `lib/app/core.dart`:

- `constant/` – application constants, keys, global flags (e.g. `APPConst`, global app IDs, storage keys in `constant/global/*`).
- `dev/` – logging infrastructure (`logger.dart`, `logging.dart`) used across the app and wallet logic.
- `error/` – exception hierarchies (`app_exception.dart`, wallet-specific errors); these are the primary error types surfaced outward.
- `external/` – integration with external APIs (e.g. CoinGecko under `external/coingeko/`).
- `http/` – HTTP abstraction layer:
  - Models and auth/manager types (`http/models/*`).
  - Isolate-based HTTP service (`http/isolate/*`) with platform-specific implementations (`io`, `web`) and message/transport models.
  - Utilities such as `digest_authenticated.dart` for authenticated requests.
- `live_listener/` – utilities for listening to long-running processes / progress (`live.dart`, `progress_bar.dart`, `timeout` logic).
- `localization/` – localization utilities used by the Flutter layer.
- `models/` – app-level models (assets, content types, currencies, settings, webview tabs/storage, typedefs).
- `native_impl/` – cross-platform bridges for native behaviors (open URL, share, path provider, core native integration for non-web platforms).
- `platform_methods/` – cross-platform method channels and platform selectors (IO/Web variants), building a uniform interface around platform differences.
- `serialization/` – CBOR and other serialization helpers shared by wallet/crypto layers.
- `utils/` – generic utilities for bytes, dates, lists/maps, URIs, platform detection, sharing, caching/sync helpers, etc.
- `websocket/` – cross-platform websocket abstraction (core, and platform-specific implementations).

Most non-UI code outside `lib/wallet` and `lib/crypto` is expected to depend on this layer (imported via `package:stealth_stash/app/core.dart`).

### Wallet domain layer (`lib/wallet`)

This layer models networks, accounts, providers, and remote services, decoupled from UI and raw cryptography.

Key submodules:

- `wallet/api/` – network API abstraction:
  - `client/` – per-network RPC/REST clients (Bitcoin/Electrum, Ethereum, Cosmos, Substrate, Tron, etc.), often composed around the app’s HTTP/socket services.
  - `provider/` – higher-level provider models for each chain type (e.g. Electrum vs explorer, Ethereum RPC endpoints, Ton/Tron RPC, etc.) and their configuration.
  - `services/` – shared service layer: protocol-specific services (HTTP, WebSocket, Electrum), connection models, and tracking logic (e.g. socket status, request completers).
  - `constant/` and `utils/` – wallet-specific constants and helper functions around networking.
- `wallet/chain/` – chain and account abstractions:
  - `core/` – generic `Chain`, `Address`, `Network`, `Params`, storage interfaces.  
  - `networks/*` – concrete implementations per chain (Aptos, Bitcoin, Cardano, Cosmos, Ethereum, Monero, Solana, Stellar, Substrate, Sui, etc.), including:
    - Account models and state objects.
    - Address and derivation logic (including multisig variants for networks that support it).
    - Network parameters and repository logic (e.g. Cosmos/Monero repositories).
  - `chain/balance/*` – typed balance representations (integer/decimal wrappers) for consistent UI/domain handling.

This layer is what the UI (`lib/future`) talks to in order to read/update wallet state, fetch balances, build transactions, etc.

### Cryptography and key management (`lib/crypto`)

The `lib/crypto` tree encapsulates chain-agnostic crypto primitives and key-management flows, often used by `lib/wallet` and app code via isolates / platform bridges.

- `coins/` – coin-specific helpers and serialization for addressing and network tags.
- `constant/` – crypto-related constants and tags.
- `crypto/` – core crypto engine:
  - `core/` – high-level app crypto APIs.
  - `cross/` – platform-dispatching crypto implementations with IO/web variants and constants.
  - `types/` – crypto type definitions and value objects.
- `impl/` and `isolate/` – isolate-based worker implementations for CPU-heavy crypto operations, with cross-platform dispatch and web/IO implementations.
- `keys/` – key and seed management:
  - Wallet master keys, imported keys, encrypted key storage formats.
  - Derivation primitives (BIP32, multisig, Substrate, etc.).
  - Request/response models for key operations and import flows.
- `platform_methods/` – platform-specific crypto method channels parallel to `lib/app/platform_methods`.
- `requests/` – (spelled `requets` in the tree) message and request models used to talk to crypto isolates, including:
  - Crypto operations (hashing, symmetric crypto, wallet key derivations).
  - Non-encrypted helpers and streaming requests.

When implementing new crypto flows or supporting a new network, align with the existing isolate/request patterns to keep heavy operations off the UI thread.

### Flutter UI, routing, and state management (`lib/future`)

`lib/future` hosts the Flutter presentation layer and a custom state-management system used by `lib/main.dart`:

- `future.dart` – public barrel exporting the wallet UI (`wallet/wallet.dart`), shared widgets, QR scanner, theme, and webview integration.
- `router/page_router.dart` – centralizes all named routes for:
  - Network-specific transaction flows (Bitcoin, Ethereum, Tron, Solana, Cosmos, Substrate, Monero, Sui, Aptos, etc.).
  - Settings/security flows (password change, panic mode, erase wallet, backup, seed/private key export).
  - Network/provider management (import networks, update providers per chain, token imports).
  - Web3/WalletConnect flows and dApp management.
  - Webview flows and global wallet screens.
- `state_managment/` – custom state layer:
  - Core types (`live`, `repository`, `state_repository`, `disposable`) and builder widgets (`StateBuilder`, `SafeState`), used heavily in `lib/main.dart` and wallet screens.
  - Extension helpers for widgets and context access.
- `wallet/` – wallet UI components:
  - Account-level views and controllers, including account creation/removal, token management, public key display, contacts, backups, and transaction flows.
  - `network/` subfolders per chain, each containing account/state models, transaction controllers, operations, widgets, and Web3 permission pages.
  - `global/` – shared wallet UI (account selectors, chain configs, amount setup, generic transaction views, etc.).
- Supporting utilities:
  - `theme/` – theme and color configuration used by `ThemeController` in `lib/main.dart`.
  - `qr_code_scanner/` – cross-platform QR scanner abstraction.
  - `tools/` – assorted tools such as frame trackers and secure state helpers.

When adding new UI flows, ensure they are wired through `PageRouter` and use the existing state-management patterns (`StateBuilder`, `StateRepository`).

### Web, JS, and WASM integration

The build and runtime integration for web and extensions relies on several directories plus `app_builder.dart`:

- `web_crypto/` – Dart entrypoints for compiling crypto logic to WebAssembly or JS (`crypto.dart`, `stream_crypto.dart`).  
- `web_http/` – Dart entrypoint for compiling the web HTTP shim to JS.
- `assets/wasm/` – runtime assets (generated `.wasm`, `.mjs`, support JS, HTTP shim) expected by the web/extension builds. `app_builder.dart` ensures these are built and cleans old artifacts.
- `js/` – Dart entrypoints for browser extension content/background/page and webview scripts.
- `requirement/` – source templates and config for extensions (`requirement/extensions/`), webview (`requirement/webview/`), WASM loader (`requirement/wasm.mjs`), and macOS DMG packaging (`requirement/dmg_installer/`).

If web or extension builds fail, check that the expected files exist under `requirement/` and that `app_builder.dart` has been run with appropriate flags.

### Platform directories and CI

- Standard Flutter platform folders (`android`, `ios`, `linux`, `macos`, `windows`, `web`) are present and follow typical Flutter layouts.
- GitHub Actions workflow `.github/workflows/dart.yml` currently targets a Windows build using a Flutter SDK downloaded at runtime and assumes a `mrt_wallet` subdirectory as the working directory. If you are updating CI, verify that this path matches the current project structure (`on_chain_wallet` at repo root) and adjust accordingly.

## Notes for future agents

- Prefer importing the app and wallet layers via their barrels: `package:stealth_stash/app/core.dart`, `package:stealth_stash/future/future.dart`, and `package:stealth_stash/wallet/api.dart` / `wallet/models/...` instead of deep relative imports.
- When introducing new networks or crypto flows, follow existing patterns in `lib/wallet/chain/` and `lib/crypto/requests/` to keep the architecture consistent and to reuse isolates/platform abstractions.
- For platform-specific issues (desktop windowing, URL launch, sharing, path provider, etc.), inspect `lib/app/native_impl` and `lib/app/platform_methods` rather than adding new ad-hoc platform channels.
