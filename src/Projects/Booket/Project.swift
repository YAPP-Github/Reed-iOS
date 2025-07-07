import ProjectDescription
import ProjectDescriptionHelpers

let appTarget = Target.target(
    name: "Booket",
    product: .app,
    bundleId: Project.bundleID,
    infoPlist: .file(path: .relativeToRoot("SupportingFiles/Info.plist")),
//    infoPlist: .default,
    sources: .sources,
    resources: [
//        .glob(pattern: .relativeToRoot("src/Resources/**")),
//        .glob(pattern: .relativeToRoot("src/Resources/LaunchScreen.storyboard"))
    ],
    entitlements: .file(path: .relativeToRoot("SupportingFiles/Booket/Booket.entitlements")),
    scripts: [
        swiftLintScript
    ],
    dependencies: [
        // Module
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
//            .debug(name: "Debug", xcconfig: "SupportingFiles/Debug.xcconfig"),
//            .release(name: "Release", xcconfig: "SupportingFiles/Release.xcconfig")
            .debug(name: "Debug", xcconfig: .relativeToRoot("SupportingFiles/Configs/Debug.xcconfig")),
            .release(name: "Release", xcconfig: .relativeToRoot("SupportingFiles/Configs/Release.xcconfig"))
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
