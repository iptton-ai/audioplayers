#!/bin/bash

# AudioPlayers OHOS 构建验证脚本
# 验证 flutter build hap 是否成功生成所需文件

echo "🔍 AudioPlayers OHOS 构建验证"
echo "================================"

# 检查HAP文件
HAP_FILE="example/ohos/entry/build/default/outputs/default/entry-default-unsigned.hap"
if [ -f "$HAP_FILE" ]; then
    echo "✅ HAP文件已生成: $HAP_FILE"
    HAP_SIZE=$(ls -lh "$HAP_FILE" | awk '{print $5}')
    echo "   文件大小: $HAP_SIZE"
else
    echo "❌ HAP文件未找到: $HAP_FILE"
    exit 1
fi

# 检查插件注册文件
PLUGIN_REG="example/ohos/entry/src/main/ets/plugins/GeneratedPluginRegistrant.ets"
if [ -f "$PLUGIN_REG" ]; then
    echo "✅ 插件注册文件已生成: $PLUGIN_REG"
    if grep -q "AudioplayersOhosPlugin" "$PLUGIN_REG"; then
        echo "   ✅ 包含audioplayers_ohos插件注册"
    else
        echo "   ❌ 未找到audioplayers_ohos插件注册"
    fi
else
    echo "❌ 插件注册文件未找到: $PLUGIN_REG"
fi

# 检查OHOS源码文件
OHOS_PLUGIN="ohos/src/main/ets/components/plugin/AudioplayersOhosPlugin.ets"
if [ -f "$OHOS_PLUGIN" ]; then
    echo "✅ OHOS插件源码存在: $OHOS_PLUGIN"
else
    echo "❌ OHOS插件源码未找到: $OHOS_PLUGIN"
fi

OHOS_PLAYER="ohos/src/main/ets/components/plugin/OHOSAudioPlayer.ets"
if [ -f "$OHOS_PLAYER" ]; then
    echo "✅ OHOS音频播放器源码存在: $OHOS_PLAYER"
else
    echo "❌ OHOS音频播放器源码未找到: $OHOS_PLAYER"
fi

# 检查Dart接口文件
DART_INTERFACE="lib/audioplayers_ohos.dart"
if [ -f "$DART_INTERFACE" ]; then
    echo "✅ Dart接口文件存在: $DART_INTERFACE"
    if grep -q "AudioplayersPlatformInterface" "$DART_INTERFACE"; then
        echo "   ✅ 实现了AudioplayersPlatformInterface"
    else
        echo "   ❌ 未实现AudioplayersPlatformInterface"
    fi
else
    echo "❌ Dart接口文件未找到: $DART_INTERFACE"
fi

# 检查pubspec.yaml配置
PUBSPEC="pubspec.yaml"
if [ -f "$PUBSPEC" ]; then
    echo "✅ pubspec.yaml存在"
    if grep -q "implements: audioplayers" "$PUBSPEC"; then
        echo "   ✅ 正确配置为audioplayers实现"
    else
        echo "   ❌ 未配置为audioplayers实现"
    fi
else
    echo "❌ pubspec.yaml未找到"
fi

echo ""
echo "🎯 构建验证总结"
echo "================================"

# 统计结果
SUCCESS_COUNT=$(echo "✅" | wc -l)
if [ -f "$HAP_FILE" ] && [ -f "$PLUGIN_REG" ] && [ -f "$OHOS_PLUGIN" ] && [ -f "$OHOS_PLAYER" ] && [ -f "$DART_INTERFACE" ]; then
    echo "🎉 构建验证成功！"
    echo ""
    echo "📋 下一步操作："
    echo "1. 在DevEco Studio中配置调试签名"
    echo "2. 安装HAP文件到OHOS设备进行测试"
    echo "3. 验证音频播放功能"
    echo ""
    echo "💡 使用方法："
    echo "cd example && flutter build hap --debug"
    exit 0
else
    echo "❌ 构建验证失败，请检查上述错误"
    exit 1
fi
