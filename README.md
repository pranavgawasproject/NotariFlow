# NotariFlow
# 1. Stop everything
pkill -f flutter

# 2. Clean the project
flutter clean

# 3. Get fresh dependencies
flutter pub get

# 4. Analyze for errors
flutter analyze

# 5. Run again
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0