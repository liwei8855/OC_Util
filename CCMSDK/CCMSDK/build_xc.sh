#!/bin/sh

TARGET_NAME=${PROJECT_NAME}

xcodebuild archive -project "${TARGET_NAME}.xcodeproj" \
-scheme "${TARGET_NAME}" \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath "../archives/${TARGET_NAME}.framework-iphonesimulator.xcarchive" \
SKIP_INSTALL=NO

xcodebuild archive -project "${TARGET_NAME}.xcodeproj" \
-scheme "${TARGET_NAME}" \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath "../archives/${TARGET_NAME}.framework-iphoneos.xcarchive" \
SKIP_INSTALL=NO


#合并xcframework
# cd xcframework文件夹路径
# xcodebuild -create-xcframework \
# -framework '../archives/CCMSDK.framework-iphoneos.xcarchive/Products/Library/Frameworks/CCMSDK.framework' \
# -framework '../archives/CCMSDK.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/CCMSDK.framework' \
# -output 'CCMSDK.xcframework'
