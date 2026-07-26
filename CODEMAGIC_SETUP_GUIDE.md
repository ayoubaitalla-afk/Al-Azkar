# Codemagic CI/CD Setup Guide for Al-Azkar

## 📋 Overview

This guide explains how to set up and configure Codemagic for automated building and testing of the Al-Azkar Flutter application. The configuration includes builds for Android (APK & AAB), iOS, Web, and HyperOS-optimized releases.

## 🚀 Getting Started with Codemagic

### Step 1: Sign Up for Codemagic

1. Visit [https://codemagic.io](https://codemagic.io)
2. Sign up with your GitHub account
3. Authorize Codemagic to access your GitHub repositories
4. You'll be taken to your Codemagic dashboard

### Step 2: Connect Your Repository

1. Click **"Add Application"** on the Codemagic dashboard
2. Select **GitHub** as the source
3. Search for `ayoubaitalla-afk/Al-Azkar`
4. Click **"Add Application"**
5. Codemagic will automatically detect the `codemagic.yaml` file

### Step 3: Configure Environment Variables

Go to **App Settings** → **Environment Variables** and add:

#### For Android Builds:
```
KEYSTORE_PATH=/Users/builder/keystore.jks
KEYSTORE_PASSWORD=your_keystore_password
KEY_PASSWORD=your_key_password
KEY_ALIAS=your_key_alias
```

#### For iOS Builds:
```
XCODE_WORKSPACE=ios/Runner.xcworkspace
XCODE_SCHEME=Runner
PROVISIONING_PROFILE_UUID=your_provisioning_profile_uuid
CODE_SIGN_IDENTITY=your_code_signing_identity
```

#### For Notifications (Optional):
```
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

### Step 4: Set Up Signing

#### Android Keystore Setup:

1. Generate keystore (if you don't have one):
```bash
keytool -genkey -v -keystore ~/al-azkar-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias al-azkar
```

2. Upload keystore to Codemagic:
   - Go to **App Settings** → **Code Signing**
   - Click **"Set up Android signing"**
   - Upload your keystore file
   - Enter the keystore password and key password

3. Update `codemagic.yaml` with your signing configuration:
```yaml
scripts:
  - name: Sign APK
    script: |
      jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
        -keystore ~/keystore.jks \
        -storepass $KEYSTORE_PASSWORD \
        -keypass $KEY_PASSWORD \
        build/app/outputs/flutter-apk/app-release-unsigned.apk $KEY_ALIAS
```

#### iOS Code Signing Setup:

1. Go to **App Settings** → **Code Signing**
2. Click **"Set up iOS signing"**
3. Follow Codemagic's guided setup:
   - Connect your Apple Developer Account
   - Select certificates and provisioning profiles
   - Codemagic will automatically manage them

## 📊 Current Build Workflows

### 1. **Flutter Build Android APK & AAB**
- **Triggers**: Push to `main` or `develop`, Pull Requests
- **Output**: APK files (split per ABI) + AAB (Google Play Bundle)
- **Tests**: Code analysis, unit tests
- **Notification**: Email on success/failure

### 2. **Flutter Build Android for HyperOS**
- **Triggers**: Push to `main`
- **Special**: Optimized for Xiaomi HyperOS 3.0.3
- **Features**: Notification optimization enabled
- **Output**: HyperOS-compatible APK & AAB

### 3. **Flutter Build iOS IPA**
- **Triggers**: Push to `main` or `develop`, Pull Requests
- **Output**: IPA file for App Store
- **Tests**: Code analysis, unit tests
- **Notification**: Email on success/failure

### 4. **Flutter Build Web**
- **Triggers**: Push to `main`
- **Special**: Skia rendering engine enabled
- **Output**: Web build artifacts
- **Notification**: Email on success/failure

### 5. **Flutter Beta Build**
- **Triggers**: Push to `develop`
- **Output**: Debug APK & AAB for testing
- **Purpose**: Internal testing and QA

## 🔧 Customizing Workflows

### Add a New Workflow

Edit `codemagic.yaml` and add:

```yaml
workflows:
  my-custom-workflow:
    name: My Custom Build
    max_build_duration: 120
    environment:
      flutter: 3.32.0
    triggering:
      events:
        - push
      branch:
        include_patterns:
          - main
    scripts:
      - name: Get dependencies
        script: flutter pub get
      - name: Build
        script: flutter build apk --release
    artifacts:
      - build/app/outputs/flutter-apk/*.apk
```

### Modify Build Triggers

Change which branches trigger builds:

```yaml
triggering:
  events:
    - push              # On push
    - pull_request      # On PR
  branch:
    include_patterns:
      - main
      - develop
      - release/**      # Match pattern
```

### Add Post-Build Actions

```yaml
publishing:
  email:
    recipients:
      - your-email@example.com
    notify:
      success: true
      failure: true
  slack:
    channel: '#builds'
    notify_on_build_start: true
```

## 📱 Testing Builds Locally

Before pushing to Codemagic, test locally:

### Android Build:
```bash
flutter build apk --release --split-per-abi
flutter build appbundle --release
```

### iOS Build:
```bash
flutter build ios --release
```

### Web Build:
```bash
flutter build web --release
```

### Debug Build:
```bash
flutter build apk --debug
```

## 🔐 Security Best Practices

### 1. **Never Commit Secrets**
- Don't commit `keystore.jks` or certificates
- Use Codemagic environment variables
- Add to `.gitignore`:
```
keystore.jks
*.jks
*.p8
*.p12
```

### 2. **Protect Sensitive Data**
- Mark environment variables as **Secure** in Codemagic
- Use separate variables for different environments
- Rotate credentials regularly

### 3. **GitHub Integration**
- Grant minimal required permissions
- Review connected apps regularly
- Use GitHub deploy keys for additional security

## 📈 Monitoring Builds

### View Build History:
1. Go to **Builds** tab in Codemagic dashboard
2. Click on any build to see details
3. Check logs for errors or warnings

### Understand Build Status:

| Status | Meaning |
|--------|---------|
| ✅ Success | Build completed successfully |
| ❌ Failed | Build failed (check logs) |
| ⏸️ Paused | Build was manually paused |
| ⏳ Building | Build in progress |

### Download Build Artifacts:

1. Click on completed build
2. Go to **Artifacts** section
3. Click download icon next to APK/AAB/IPA

## 🐛 Troubleshooting

### Build Fails with "Flutter not found"
**Solution**: Check Flutter version in `codemagic.yaml`:
```yaml
environment:
  flutter: 3.32.0  # Ensure this version is available
```

### Android Signing Fails
**Solution**: Verify keystore credentials:
```bash
keytool -list -v -keystore ~/keystore.jks
```

### Notification Permission Issues
**Solution**: Add to Android manifest (already included in our config)
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Build Timeout
**Solution**: Increase `max_build_duration` in `codemagic.yaml`:
```yaml
max_build_duration: 180  # 3 hours
```

### Out of Memory During Build
**Solution**: Add to scripts:
```bash
export GRADLE_OPTS='-Xmx2048m -XX:MaxPermSize=512m'
```

## 📧 Email Notifications

### Configure Recipients:

Edit `codemagic.yaml`:
```yaml
publishing:
  email:
    recipients:
      - ayoub.aitalla@uit.ac.ma
      - team@example.com
    notify:
      success: true      # Email on success
      failure: true      # Email on failure
```

### Email Templates:

You can customize email templates in Codemagic dashboard:
1. Go to **Team Settings** → **Notifications**
2. Customize email templates
3. Add custom branding/messages

## 🔄 Integration with GitHub

### Auto-Triggering Builds:

Builds automatically trigger on:
- ✅ Push to configured branches
- ✅ Pull requests to configured branches
- ❌ Force pushes (configurable)

### Commit Status Updates:

Codemagic automatically updates GitHub PR status:
- Shows build status on PR
- Blocks merge if build fails (if required)
- Shows success/failure details

## 📊 Advanced Configurations

### Build Variants:

Create separate workflows for different build types:

```yaml
workflows:
  release-build:
    name: Release Build
    triggering:
      branch:
        include_patterns:
          - main
    scripts:
      - name: Build Release
        script: flutter build apk --release
  
  debug-build:
    name: Debug Build
    triggering:
      branch:
        include_patterns:
          - develop
    scripts:
      - name: Build Debug
        script: flutter build apk --debug
```

### Conditional Scripting:

```yaml
scripts:
  - name: Build APK (Conditional)
    script: |
      if [ "$CM_BRANCH" = "main" ]; then
        flutter build apk --release
      else
        flutter build apk --debug
      fi
```

### Multi-Step Build Process:

```yaml
scripts:
  - name: Step 1 - Get Dependencies
    script: flutter pub get
  
  - name: Step 2 - Analyze
    script: flutter analyze
  
  - name: Step 3 - Test
    script: flutter test
  
  - name: Step 4 - Build
    script: flutter build apk --release
```

## 🎯 HyperOS Optimization

The workflow `flutter-build-android-huawei` includes special optimizations:

```yaml
flutter build apk --release \
  --dart-define=ENABLE_NOTIFICATION_OPTIMIZATIONS=true \
  --split-per-abi
```

This ensures:
- ✅ Notification system works on Xiaomi HyperOS
- ✅ Battery optimization compatible
- ✅ MIUI-specific features enabled
- ✅ Exact alarm scheduling functional

## 📱 Deploying to App Stores

### Google Play Store:

1. Set up service account in Codemagic:
   - Go to **App Settings** → **App Store Connect / Google Play Console**
   - Upload service account JSON

2. Add to `codemagic.yaml`:
```yaml
publishing:
  google_play:
    credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
    track: internal  # internal, alpha, beta, production
```

### Apple App Store:

1. Set up App Store Connect credentials
2. Configure in Codemagic dashboard
3. Add to `codemagic.yaml`:
```yaml
publishing:
  app_store_connect:
    auth: integration
```

## 📚 Useful Resources

- [Codemagic Documentation](https://docs.codemagic.io)
- [Flutter Build Documentation](https://flutter.dev/docs/deployment)
- [Android App Signing](https://flutter.dev/docs/deployment/android#signing-the-app)
- [iOS App Signing](https://flutter.dev/docs/deployment/ios#signing-the-app)

## ✅ Implementation Checklist

- [ ] Sign up for Codemagic
- [ ] Connect GitHub repository
- [ ] Configure environment variables
- [ ] Set up Android signing
- [ ] Set up iOS signing (if applicable)
- [ ] Configure email notifications
- [ ] Test first build manually
- [ ] Configure branch protection rules
- [ ] Set up Slack notifications (optional)
- [ ] Document for team
- [ ] Set up artifact retention policy

## 🔗 Quick Links

- **Codemagic Dashboard**: https://codemagic.io/app/al-azkar
- **GitHub Repository**: https://github.com/ayoubaitalla-afk/Al-Azkar
- **Codemagic Docs**: https://docs.codemagic.io
- **Flutter Deployment Docs**: https://flutter.dev/docs/deployment

## 📞 Support

For Codemagic issues:
- Check [Codemagic Status Page](https://status.codemagic.io)
- Visit [Codemagic Community](https://community.codemagic.io)
- Contact [Codemagic Support](https://codemagic.io/contact)

---

**Version**: 1.0
**Last Updated**: July 26, 2026
**Compatible With**: Flutter 3.32.0+, Codemagic
