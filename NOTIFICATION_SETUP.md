# Period Reminder Notification Setup Guide

## Overview
This app now includes a **period reminder notification system** that works across all platforms (web, mobile, Windows, macOS, Linux). Users can enable notifications from the calendar page (bell icon) to receive reminders about their upcoming periods.

## How It Works

### 1. **Notification Service** ([lib/services/notification_service.dart](lib/services/notification_service.dart))
- Manages Firebase Cloud Messaging (FCM) for cross-platform notifications
- Uses `flutter_local_notifications` for local notification delivery
- Calculates when the next period is expected (28-day default cycle)
- Schedules reminders 1 day before the expected period

### 2. **Calendar Integration** ([lib/screens/calendar_page.dart](lib/screens/calendar_page.dart))
- Bell icon in the top-right to enable/disable notifications
- Displays "Days until next period" below the period start date
- Automatically schedules notifications when a period date is saved (if notifications are enabled)
- Cancels all notifications when disabled

### 3. **Main App Initialization** ([lib/main.dart](lib/main.dart))
- Initializes notification service on app startup
- Requests necessary permissions for iOS, Android, and web

## Platform-Specific Setup

### Android Setup

1. **Update AndroidManifest.xml** (`android/app/src/main/AndroidManifest.xml`)
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
   ```

2. **Update build.gradle** (`android/app/build.gradle.kts`)
   ```kotlin
   android {
       compileSdk = 34  // or higher
       
       defaultConfig {
           targetSdk = 34  // or higher
       }
   }
   ```

3. **Add notification icon**
   - Place notification icon in `android/app/src/main/res/drawable/app_icon.png`
   - Should be a white icon with transparent background

### iOS Setup

1. **Update Info.plist** (`ios/Runner/Info.plist`)
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>remote-notification</string>
   </array>
   ```

2. **Enable push notifications capability** in Xcode:
   - Open `ios/Runner.xcworkspace`
   - Select "Runner" target → Capabilities
   - Toggle "Push Notifications" ON

### Web Setup

Notifications on web use local browser notifications. No additional setup required beyond Firebase configuration.

### Windows/macOS Setup

Ensure `flutter_local_notifications` is properly configured:
- Windows: Uses Windows Toast Notifications
- macOS: Uses macOS user notifications

## Firebase Cloud Messaging (FCM) Configuration

### 1. **Google Services Files**
The app already has:
- `android/app/google-services.json` - Android
- `ios/Runner/GoogleService-Info.plist` - iOS (needs to be added if not present)

### 2. **FCM Token**
The app automatically:
- Retrieves the FCM token on initialization
- Saves it to Firestore (optional, for backend notifications)
- Prints it to console for debugging

### 3. **Enable Firebase Cloud Messaging**
In Firebase Console:
1. Go to **Cloud Messaging** tab
2. Make sure FCM API is enabled
3. Check that service account has necessary permissions

## Usage

### For Users

1. **Open Calendar Page** - Navigate to the calendar section
2. **Add Period Date** - Select the first day of your period and click "Save Date"
3. **Enable Notifications** - Click the bell icon (🔔) in the top-right
4. **View Reminder Info** - See "Days until next period" below the period start date

### For Developers

#### Check Notification Status
```dart
// Get days until next period
int days = NotificationService()
    .calculateDaysUntilNextPeriod(
        periodStartDate: DateTime(2026, 7, 1)
    );
```

#### Manually Schedule Notification
```dart
await NotificationService().scheduleNextPeriodReminder(
    periodStartDate: DateTime(2026, 7, 1),
    periodLength: 5,
    daysBeforeNotification: 1,
);
```

#### Cancel Notifications
```dart
await NotificationService().cancelAllNotifications();
```

## Testing

### Android/iOS Testing
1. Build and run the app on device/emulator
2. Enable notifications from bell icon
3. Set period date in calendar
4. Verify notification appears 1 day before expected period
5. Check logcat/console for debug messages

### Web Testing
1. Run `flutter run -d chrome`
2. Allow browser notifications when prompted
3. Enable notifications from bell icon
4. Check browser notification center

### Debugging
Enable debug logging:
- Check console output for FCM tokens
- Look for "Period reminder scheduled successfully" message
- Check app logs for any error messages

## Files Modified/Created

- ✅ **pubspec.yaml** - Added `firebase_messaging` and `flutter_local_notifications`
- ✅ **lib/services/notification_service.dart** - New notification service
- ✅ **lib/main.dart** - Initialize notifications on app start
- ✅ **lib/screens/calendar_page.dart** - Integrate notifications with calendar UI
- ⚠️ **android/app/src/main/AndroidManifest.xml** - Needs POST_NOTIFICATIONS permission
- ⚠️ **ios/Runner/Info.plist** - Needs remote notification capability
- ⚠️ **ios/Runner/GoogleService-Info.plist** - May need to be added if missing

## Troubleshooting

### Notifications Not Showing
1. Check if notifications are enabled from bell icon
2. Verify device has notification permissions granted
3. Check app is in `pubspec.yaml`: `flutter pub get`
4. For Android: Check notification icon is present and valid
5. Check console for error messages

### FCM Token Not Generated
1. Ensure Firebase is initialized before using NotificationService
2. Check internet connection
3. Verify Firebase project is correctly set up
4. Check `google-services.json` is valid

### Permission Errors
1. For Android 13+: Grant notification permission manually in app settings
2. For iOS: Enable push notifications in Settings > Notifications
3. Rebuild app after adding permissions

### Notifications on Web
- Use Chrome/Firefox/Edge (not Safari on macOS initially)
- Grant browser notification permission when prompted
- Check browser's notification settings

## Future Enhancements

- [ ] Customize notification reminder days before period
- [ ] Multiple reminders per cycle
- [ ] Sound and vibration customization
- [ ] Notification history/logs
- [ ] Server-side scheduling using Cloud Functions
- [ ] Integration with calendar apps
- [ ] Smart reminder time based on user preferences

## Dependencies Added

- `firebase_messaging: ^15.0.0` - Cross-platform notifications
- `flutter_local_notifications: ^17.0.0` - Local notification delivery

## Documentation Links

- [Firebase Cloud Messaging Docs](https://firebase.flutter.dev/docs/messaging/overview)
- [Flutter Local Notifications Docs](https://pub.dev/packages/flutter_local_notifications)
- [Flutter Platform Channels](https://docs.flutter.dev/development/platform-integration/platform-channels)
