import ProjectDescription
import ProjectDescriptionHelpers

let appTarget = Target.target(
    name: "Booket",
    product: .app,
    bundleId: Project.bundleID,
    infoPlist: .file(path: .relativeToRoot("SupportingFiles/Booket/Info.plist")),
    sources: .sources,
    resources: [
        .glob(pattern: .relativeToRoot("Projects/Booket/Resources/LaunchScreen.storyboard")),
        .glob(pattern: .relativeToRoot("Projects/BKDesign/Resources/Font/**"))
    ],
    entitlements: .file(path: .relativeToRoot("SupportingFiles/Booket/Booket.entitlements")),
    scripts: [
        swiftLintScript
    ],
    dependencies: [
        .data(),
        .presentation(),
        .core(),
        .design(),
        .network(),
        .storage(),
        .domain()
    ],
    settings: .settings(
        base: [
            "DEVELOPMENT_LANGUAGE": "ko",
            "DEVELOPMENT_TEAM": "VZC79KP79S",
            "CODE_SIGN_STYLE": "Manual",
            "PROVISIONING_PROFILE_SPECIFIER": "match Development Booket.26th.yapp"
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: .relativeToRoot("SupportingFiles/Booket/Debug.xcconfig")),
            .release(name: "Release", xcconfig: .relativeToRoot("SupportingFiles/Booket/Release.xcconfig"))
        ]
    )
)

// MARK: - Project
let project = Project.project(
    name: "Booket",
    targets: [
        appTarget
    ]
)
