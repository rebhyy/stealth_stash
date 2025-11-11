# SQLite3MultipleCiphers FFI

This app uses **SQLite3MultipleCiphers** as its database engine on non-web platforms.  
The native C library is built externally (`.so`, `.dll`, `.dylib`, `.a`, `.lib`) and must be included with the Flutter app for each supported OS.  

---

## 🔧 Building the Native Library

Clone and build [SQLite3MultipleCiphers](https://github.com/utelle/SQLite3MultipleCiphers) with **CMake** or your platform toolchain.  
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
android/app/src/main/jniLibs/arm64-v8a/libsqlite3mc.so
android/app/src/main/jniLibs/armeabi-v7a/libsqlite3mc.so
android/app/src/main/jniLibs/x86/libsqlite3mc.so
android/app/src/main/jniLibs/x86-64/libsqlite3mc.so
```

### Macos

```
macos/Runner/Frameworks/libsqlite3mc.dylib
```

### Windows

```
windows/libsqlite3mc.dll
```