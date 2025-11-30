# CI/CD Setup Instructions

This repository is set up with GitHub Actions to automatically build Android and iOS applications.

## Prerequisites

### 1. Generate Platform Folders
Currently, the `android` and `ios` folders seem to be missing from the repository. You must generate them for the build to succeed.

Run the following command in your local development environment (where Flutter is installed):

```bash
flutter create .
```

Then commit and push the changes:

```bash
git add android ios
git commit -m "Add platform folders"
git push
```

### 2. Android Signing (Optional for Debug/Unsigned Release)
The current workflow builds a release APK. By default, Flutter might sign it with a debug key or fail if no key is configured.
To set up proper signing for the Play Store:
1. Generate a keystore.
2. Configure `android/key.properties` (do not commit this file).
3. Use GitHub Secrets to inject the keystore and properties during the build.

### 3. iOS Signing
The current workflow builds an **unsigned** iOS app (`Runner.app`) because building a signed `.ipa` requires an Apple Developer Account and certificates.
To enable signed builds (IPA):
1. You need to set up Fastlane or manually configure certificates in Xcode.
2. Add your distribution certificate and provisioning profile to GitHub Secrets.
3. Update the workflow to use `flutter build ipa`.

## Versioning
The workflow automatically versions the app using the GitHub Run Number:
- Version Name: `1.0.<run_number>`
- Build Number: `<run_number>`

You can find the build artifacts (APK and iOS App) in the "Actions" tab of your GitHub repository under the specific run.
