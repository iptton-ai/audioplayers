#!/bin/bash

# Build script for audioplayers_ohos HAR file

set -e

echo "🔨 Building audioplayers_ohos HAR file..."

# Navigate to the ohos directory
cd "$(dirname "$0")/ohos"

# Check if required files exist
if [ ! -f "oh-package.json5" ]; then
    echo "❌ oh-package.json5 not found"
    exit 1
fi

if [ ! -f "src/main/module.json5" ]; then
    echo "❌ module.json5 not found"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
ohpm install

# Create output directory
mkdir -p build/outputs/har

# Create a simple HAR structure
echo "📁 Creating HAR structure..."

# Copy source files to build directory
mkdir -p build/har/src/main/ets
cp -r src/main/ets/* build/har/src/main/ets/

# Copy resources
if [ -d "src/main/resources" ]; then
    mkdir -p build/har/src/main/resources
    cp -r src/main/resources/* build/har/src/main/resources/
fi

# Copy module.json5
cp src/main/module.json5 build/har/module.json5

# Copy oh-package.json5
cp oh-package.json5 build/har/oh-package.json5

# Create index.d.ets for TypeScript declarations
cat > build/har/index.d.ets << 'EOF'
export { AudioplayersOhosPlugin } from './src/main/ets/com/example/audioplayers_ohos/AudioplayersOhosPlugin';
export { OHOSAudioPlayer } from './src/main/ets/com/example/audioplayers_ohos/OHOSAudioPlayer';
EOF

# Create the HAR archive
echo "📦 Creating HAR archive..."
cd build/har
tar -czf ../outputs/har/audioplayers_ohos.har .
cd ../..

echo "✅ HAR file created successfully at: build/outputs/har/audioplayers_ohos.har"

# Verify the HAR file
if [ -f "build/outputs/har/audioplayers_ohos.har" ]; then
    echo "📊 HAR file size: $(du -h build/outputs/har/audioplayers_ohos.har | cut -f1)"
    echo "📋 HAR file contents:"
    tar -tzf build/outputs/har/audioplayers_ohos.har | head -20
else
    echo "❌ Failed to create HAR file"
    exit 1
fi

echo "🎉 Build completed successfully!"
