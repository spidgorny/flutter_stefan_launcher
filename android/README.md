# Android Build and Deployment with Fastlane
# Keystore Generation Instructions

## Generate a keystore file

To generate the `upload-keystore.jks` file, run the following command in your terminal from the root of your project:

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

You'll be prompted to:
1. Enter a password for the keystore (use this as `storePassword` in key.properties)
2. Enter your name, organization, and location details
3. Enter a password for the key (use this as `keyPassword` in key.properties)

## Update key.properties file

After generating the keystore, update the `android/key.properties` file with your actual passwords:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=../upload-keystore.jks
```

## Important Security Notice

- **NEVER commit your keystore file or key.properties to version control**
- Add both files to your .gitignore
- Store backups of these files securely - if lost, you won't be able to update your app on the Play Store

## Verifying the configuration

You can build a release APK to verify everything is configured correctly:

```bash
flutter build apk --release
```
This README provides instructions for using Fastlane to automate building and deploying your Android app to the Google Play Store.

## Prerequisites

1. Install Ruby (if not already installed)
2. Install Fastlane:
   ```bash
   gem install fastlane -NV
   ```
3. Set up Google Play Console API access and download the API key JSON file

## Setup

1. Edit the `fastlane/Appfile` to set your package name and path to the Google Play API key file
2. Make sure your app's signing configuration is properly set up in `app/build.gradle`

## Available Lanes

### Internal Testing

To build and upload to the internal testing track:

```bash
cd android && fastlane internal
```

### Beta Testing

To build and upload to the beta testing track:

```bash
cd android && fastlane beta
```

### Production Release

To build and upload to the production track:

```bash
cd android && fastlane production
```

## Customizing

Edit the `fastlane/Fastfile` to customize the build and deployment process according to your specific requirements.

## Troubleshooting

- If you encounter issues with building, make sure your Flutter environment is properly set up
- For Fastlane-specific issues, check the [Fastlane documentation](https://docs.fastlane.tools/)
- For Google Play Console API issues, verify your API access permissions and key file
