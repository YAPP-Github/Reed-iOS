#!/bin/bash

MODULES=(
  "BKCore"
  "BKData"
  "BKDesign"
  "BKDomain"
  "BKNetwork"
  "BKPresentation"
  "BKStorage"
  "Booket"
)

echo "모듈 디렉토리 확인 및 생성 중..."

for MODULE in "${MODULES[@]}"; do
  CREATED=false

  SOURCE_DIR="Projects/$MODULE/Sources"
  RESOURCE_DIR="Projects/$MODULE/Resources"
  TEST_DIR="Projects/$MODULE/Tests"

  [ ! -d "$SOURCE_DIR" ] && mkdir -p "$SOURCE_DIR" && CREATED=true
  [ ! -d "$RESOURCE_DIR" ] && mkdir -p "$RESOURCE_DIR" && CREATED=true
  [ ! -d "$TEST_DIR" ] && mkdir -p "$TEST_DIR" && CREATED=true

  if [ -d "$SOURCE_DIR" ] && [ -z "$(ls -A "$SOURCE_DIR")" ]; then
    echo "// Placeholder for Tuist module: $MODULE" > "$SOURCE_DIR/Placeholder.swift"
    CREATED=true
  fi

  if [ "$CREATED" = true ]; then
    echo "✅ $MODULE 디렉토리 및 placeholder 생성"
  else
    echo "✅ $MODULE은 이미 초기화되어 있음"
  fi
done

echo ""
echo "🔧 Config 파일 확인 중..."

CONFIG_DIR="SupportingFiles/Booket"
DEBUG_XCCONFIG="$CONFIG_DIR/Debug.xcconfig"
RELEASE_XCCONFIG="$CONFIG_DIR/Release.xcconfig"

if [ ! -f "$DEBUG_XCCONFIG" ]; then
  mkdir -p "$CONFIG_DIR"
  echo "// Default Debug configuration" > "$DEBUG_XCCONFIG"
  echo "✅ Debug.xcconfig 생성됨 at $DEBUG_XCCONFIG"
fi

if [ ! -f "$RELEASE_XCCONFIG" ]; then
  mkdir -p "$CONFIG_DIR"
  echo "// Default Debug configuration" > "$RELEASE_XCCONFIG"
  echo "✅ Debug.xcconfig 생성됨 at $RELEASE_XCCONFIG"
fi