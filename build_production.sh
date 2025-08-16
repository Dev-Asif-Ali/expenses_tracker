#!/bin/bash

echo "🚀 Building Expenses Tracker for Production..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for Android (APK)
echo "🤖 Building Android APK..."
flutter build apk --release --target-platform android-arm64

# Build for Android (App Bundle - recommended for Play Store)
echo "📱 Building Android App Bundle..."
flutter build appbundle --release --target-platform android-arm64

# Build for iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building iOS..."
    flutter build ios --release --no-codesign
else
    echo "⚠️  Skipping iOS build (not on macOS)"
fi

# Build for Web
echo "🌐 Building Web version..."
flutter build web --release

echo "✅ Production builds completed!"
echo ""
echo "📁 Build outputs:"
echo "   Android APK: build/app/outputs/flutter-apk/app-release.apk"
echo "   Android Bundle: build/app/outputs/bundle/release/app-release.aab"
echo "   Web: build/web/"
echo ""
echo "🚀 Ready for deployment!"
