#!/bin/bash

# NotaryFlow Quick Rebuild Script
# This script rebuilds and serves the app in optimized production mode

echo "🚀 NotaryFlow Quick Rebuild Script"
echo "=================================="
echo ""

# Navigate to project directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR" || exit 1

# Add Flutter to PATH
if [ -d "/workspaces/flutter/bin" ]; then
    export PATH="$PATH:/workspaces/flutter/bin"
elif [ -d "/home/ubuntu/flutter/bin" ]; then
    export PATH="$PATH:/home/ubuntu/flutter/bin"
fi

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

echo "📦 Cleaning previous build..."
flutter clean

echo "📥 Getting dependencies..."
flutter pub get

echo "🔨 Building production web app..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "🌐 Starting web server on port 8080..."
    echo "📱 Access your app at:"
    echo "   - Local: http://localhost:8080"
    echo "   - Codespace: Check Ports tab for forwarded URL"
    echo ""
    echo "Press Ctrl+C to stop the server"
    echo ""
    
    # Navigate to build output
    cd build/web || exit 1
    
    # Start Python HTTP server
    python3 -m http.server 8080 --bind 0.0.0.0
else
    echo "❌ Build failed. Check errors above."
    exit 1
fi
