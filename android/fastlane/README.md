This README provides instructions for using Fastlane to automate building and deploying your Android app to the Google Play Store.

## Prerequisites

1. Install Ruby (if not already installed)
2. Install Fastlane:
   ```bash
   gem install fastlane -NV
   ```
3. Set up Google Play Console API access and download the API key JSON file:
   - Go to the [Google Play Console](https://play.google.com/console)
   - Navigate to "Setup" > "API access" in the left sidebar
   - Click on "Create service account" which will redirect you to Google Cloud Platform
   - Create a new service account with a descriptive name (e.g., "fastlane-deploy")
   - Once created, click on the service account email address
   - Go to the "Keys" tab and click "Add Key" > "Create new key"
   - Select JSON format and click "Create"
   - The JSON key file will be automatically downloaded to your computer
   - Go back to the Play Console and grant the required permissions to this service account:
     - Click on "Grant access" next to your service account
     - Select the app you want to manage
     - Assign "Release Manager" role (or higher if needed)
   - Store this JSON file securely and update your Appfile with its path
