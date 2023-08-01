commands

```
# run on macos native
# advantage to do this is that it runs lighter and has hot reload
flutter run -d macos 

# run on macos native
# advantage to do this is that it runs lighter and has hot reload
flutter run -d macos 

# publish

flutter build ipa && open ./build/ios/ipa && open /Applications/Transporter.app

# rename app

https://pub.dev/packages/rename

pub global activate rename

flutter pub global run rename --appname "Conference Radio"

flutter pub global run rename --bundleId org.conferenceradio.app

# change icon

flutter pub get
flutter pub run flutter_launcher_icons:main

# to run the build runner

flutter pub run build_runner build

# If you get 
```i  functions: packaged /Users/hunterwilhelm/development/mysite-app/functions (107.24 KB) for uploading

Error: An unexpected error has occurred.
```
Delete the broken function here
https://console.cloud.google.com/functions/list


### Secrets to copy
android/key.properties
upload_ipa.sh
lib/firebase_options.dart
functions/.env
~/.android/debug.keystore
~/.android/debug.keystore.lock