# Monero Unlock FFI

This file contains native C functions for efficiently detecting
which outputs in a Monero transaction belong to a set of accounts.
It uses the account's view secret keys and spend public keys to
derive and compare output public keys, returning matching outputs.


## 🔧 Building the Native Library

Clone and build  with **CMake** or your platform toolchain.  
The result will be platform-specific shared libraries:

- **Android:** `.so` files  
- **Windows:** `.dll` + `.lib`  
- **macOS:** `.dylib` or `.framework`  
- **iOS:** `.a` (static library)  

---

## 📂 Placement in App Project

After building, copy the native libraries into the correct platform folders:

### Android
After building the `.so` libraries for each target ABI, place them in your Flutter project so the Android build system can include them automatically.  

Each ABI folder corresponds to a specific processor architecture:

- `arm64-v8a` → 64-bit ARM devices  
- `armeabi-v7a` → 32-bit ARM devices  
- `x86` → 32-bit Intel emulators  
- `x86-64` → 64-bit Intel emulators  


```
android/app/src/main/jniLibs/arm64-v8a/libed25519.so
android/app/src/main/jniLibs/armeabi-v7a/libed25519.so
android/app/src/main/jniLibs/x86/libed25519.so
android/app/src/main/jniLibs/x86-64/libed25519.so
```

### Macos

```
macos/Runner/Frameworks/libed25519.dylib
```

### Windows

```
windows/libed25519.dll
```