#!/bin/bash

# Verification script for audioplayers_ohos HAR file

set -e

echo "🔍 Verifying audioplayers_ohos HAR file..."

HAR_FILE="ohos/build/outputs/har/audioplayers_ohos.har"

# Check if HAR file exists
if [ ! -f "$HAR_FILE" ]; then
    echo "❌ HAR file not found: $HAR_FILE"
    echo "💡 Run ./build_har.sh first to generate the HAR file"
    exit 1
fi

echo "✅ HAR file found: $HAR_FILE"
echo "📊 File size: $(du -h "$HAR_FILE" | cut -f1)"

# Create temporary directory for extraction
TEMP_DIR=$(mktemp -d)
echo "📁 Extracting HAR to temporary directory: $TEMP_DIR"

# Extract HAR file
ORIGINAL_DIR=$(pwd)
cd "$TEMP_DIR"
tar -xzf "$ORIGINAL_DIR/$HAR_FILE" 2>/dev/null || {
    echo "❌ Failed to extract HAR file"
    rm -rf "$TEMP_DIR"
    exit 1
}

echo "📋 HAR file structure:"
find . -type f | sort

echo ""
echo "🔍 Checking required files..."

# Check required files
REQUIRED_FILES=(
    "oh-package.json5"
    "module.json5"
    "index.d.ets"
    "src/main/ets/index.ets"
    "src/main/ets/com/example/audioplayers_ohos/AudioplayersOhosPlugin.ts"
    "src/main/ets/com/example/audioplayers_ohos/OHOSAudioPlayer.ts"
    "src/main/resources/base/element/string.json"
)

ALL_GOOD=true

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ Missing: $file"
        ALL_GOOD=false
    fi
done

echo ""
echo "🔍 Checking file contents..."

# Check oh-package.json5
if [ -f "oh-package.json5" ]; then
    echo "📄 oh-package.json5 content:"
    cat oh-package.json5 | head -10
    echo ""
fi

# Check module.json5
if [ -f "module.json5" ]; then
    echo "📄 module.json5 content:"
    cat module.json5 | head -10
    echo ""
fi

# Check index.d.ets
if [ -f "index.d.ets" ]; then
    echo "📄 index.d.ets content:"
    cat index.d.ets
    echo ""
fi

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

if [ "$ALL_GOOD" = true ]; then
    echo "🎉 HAR file verification completed successfully!"
    echo "✅ All required files are present"
    echo "📦 HAR file is ready for use"
else
    echo "❌ HAR file verification failed"
    echo "💡 Some required files are missing"
    exit 1
fi
