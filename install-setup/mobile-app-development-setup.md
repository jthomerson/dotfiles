# Mobile App Development Setup

This guide covers setting up iOS and Android development for Tauri apps, including
running on simulators/emulators and physical devices.

## Prerequisites

Before starting, ensure you have completed the basic setup from the main README:

* Node.js v24+
* pnpm 9+
* Rust toolchain

## iOS Development

### Install iOS Prerequisites

1. **Install Xcode** (full version, not just Command Line Tools):

   * Download from the [Mac App Store][xcode-app-store]
   * Or download from [Apple Developer][apple-developer]

2. **Launch Xcode** after installation to complete setup:

   * Open Xcode
   * Accept the license agreement
   * Let it install additional components

3. **Install CocoaPods** (dependency manager for iOS):

   ```bash
   brew install cocoapods
   ```

4. **Install iOS development tools**:

   ```bash
   brew install libimobiledevice
   ```

### Initialize iOS Project

From the `apps/mobile` directory:

```bash
pnpm tauri ios init
```

This will:

* Install iOS Rust targets (`aarch64-apple-ios`, `aarch64-apple-ios-sim`,
  `x86_64-apple-ios`)
* Install `xcodegen` if needed
* Generate the Xcode project in `src-tauri/gen/apple`

### Running on iOS Simulator

```bash
pnpm tauri ios dev
```

This opens the app in the iOS Simulator. The first build takes longer due to Rust
compilation.

To specify a particular simulator:

```bash
pnpm tauri ios dev "iPhone 15 Pro"
```

### Running on Physical iOS Device

1. **Set up code signing**:

   * You need an Apple Developer account (free tier works for development)
   * Open the Xcode project: `open src-tauri/gen/apple/[PROJECTNAME].xcodeproj`
   * Select your development team in Signing & Capabilities

2. **Configure development team** in `tauri.conf.json`:

   ```json
   {
      "bundle": {
         "iOS": {
            "developmentTeam": "YOUR_TEAM_ID"
         }
      }
   }
   ```

   Or set the environment variable:

   ```bash
   export APPLE_DEVELOPMENT_TEAM="YOUR_TEAM_ID"
   ```

   To find your team ID, run `tauri info` or check in Xcode under your account settings.

3. **Connect your device** via USB and trust the computer on the device.

4. **Run on device**:

   ```bash
   pnpm tauri ios dev --open
   ```

   This opens Xcode where you can select your physical device and run.

## Android Development

### Install Android Prerequisites

1. **Install Android Studio**:

   * Download from [developer.android.com][android-studio]
   * Run the installer and complete the setup wizard

2. **Install SDK components** via Android Studio:

   * Open Android Studio > Settings > Languages & Frameworks > Android SDK
   * SDK Platforms tab: Install your target Android version(s)
   * SDK Tools tab: Install:
      * Android SDK Build-Tools
      * Android SDK Command-line Tools
      * Android SDK Platform-Tools
      * NDK (Side by side) - version 28+ recommended

3. **Install Java JDK 17+** (if not already installed):

   ```bash
   brew install openjdk@17
   ```

4. **Set environment variables** in your shell profile (`~/.zshrc` or `~/.bashrc`):

   ```bash
   export ANDROID_HOME="$HOME/Library/Android/sdk"
   export NDK_HOME="$ANDROID_HOME/ndk/$(ls -1 $ANDROID_HOME/ndk | tail -1)"
   export PATH="$ANDROID_HOME/platform-tools:$PATH"
   export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
   ```

   Then reload your shell:

   ```bash
   source ~/.zshrc
   ```

5. **Accept Android licenses**:

   ```bash
   sdkmanager --licenses
   ```

### Initialize Android Project

From the `apps/mobile` directory:

```bash
pnpm tauri android init
```

This will:

* Install Android Rust targets
* Generate the Android project in `src-tauri/gen/android`

### Running on Android Emulator

1. **Create an emulator** via Android Studio:

   * Open Android Studio
   * Tools > Device Manager
   * Create Device > Select a phone (e.g., Pixel 7)
   * Select a system image (download if needed)
   * Finish

2. **Start the emulator** from Device Manager or command line:

   ```bash
   emulator -avd <emulator_name>
   ```

3. **Run the app**:

   ```bash
   pnpm tauri android dev
   ```

### Running on Physical Android Device

1. **Enable Developer Options** on your device:

   * Go to Settings > About phone
   * Tap "Build number" 7 times
   * Go back to Settings > Developer options
   * Enable "USB debugging"

2. **Connect your device** via USB:

   * When prompted on the device, allow USB debugging from your computer

3. **Verify connection**:

   ```bash
   adb devices
   ```

   Your device should appear in the list.

4. **Run the app**:

   ```bash
   pnpm tauri android dev
   ```

   If multiple devices/emulators are connected, you'll be prompted to choose one.

## Troubleshooting

### iOS

* **"No code signing certificates found"**: Set up your development team in Xcode or
  via `APPLE_DEVELOPMENT_TEAM` environment variable.
* **CocoaPods errors**: Try `pod repo update` and re-run the init command.
* **Simulator not starting**: Ensure Xcode is fully installed and run
  `xcode-select -s /Applications/Xcode.app`.

### Android

* **"SDK location not found"**: Verify `ANDROID_HOME` is set correctly.
* **NDK not found**: Ensure `NDK_HOME` points to a valid NDK installation.
* **Device not appearing**: Check USB cable, enable USB debugging, and try
  `adb kill-server && adb start-server`.
* **Gradle build failures**: Try `cd src-tauri/gen/android && ./gradlew clean`.

## Development Server for Physical Devices

When running on a physical device (not simulator/emulator), the device needs to connect
to your development server. Set the dev host:

```bash
export TAURI_DEV_HOST=$(ipconfig getifaddr en0)
pnpm tauri [ios|android] dev
```

This tells the app to connect to your machine's local IP instead of localhost.

## Building for Release

### iOS

```bash
pnpm tauri ios build
```

Output: `src-tauri/gen/apple/build/` - Use Xcode to archive and upload to App Store.

### Android

```bash
pnpm tauri android build
```

Output: `src-tauri/gen/android/app/build/outputs/` - APK or AAB for Google Play.

[xcode-app-store]: https://apps.apple.com/app/xcode/id497799835
[apple-developer]: https://developer.apple.com/xcode/
[android-studio]: https://developer.android.com/studio
