import ProjectDescription
import Foundation

let projectDir = ProcessInfo.processInfo.environment["PROJECT_DIR"] ?? ""
let swiftLintConfigPath = "\(projectDir)/../../.swiftlint.yml"


public let swiftLintScript: TargetScript = .pre(
    script: """
    export PATH="/opt/homebrew/bin:$PATH"
    
    SWIFTLINT_PATH=$(which swiftlint)
    SWIFTLINT_CONFIG_PATH="${SRCROOT%/*/*}/.swiftlint.yml"
        
    if [ -n "$SWIFTLINT_PATH" ]; then
        swiftlint --config "$SWIFTLINT_CONFIG_PATH"
    else
        echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    fi
    """,
    name: "SwiftLint",
    basedOnDependencyAnalysis: false
)

public let crashScript: TargetScript = .post(
    script: """
    "${SRCROOT}/../../Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"
    """,
    name: "Firebase Crashlytics",
    inputPaths: [
        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}",
        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
        "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
        "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)"
    ],
    basedOnDependencyAnalysis: true
)
