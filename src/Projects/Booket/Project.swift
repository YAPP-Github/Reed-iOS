import ProjectDescription
import ProjectDescriptionHelpers

let debugAppTarget = Target.target(
    name: "Reed-Debug",
    product: .app,
    bundleId: Project.bundleID,
    infoPlist: .file(path: .relativeToRoot("SupportingFiles/Booket/Info.plist")),
    sources: .sources,
    resources: [
        .glob(pattern: .relativeToRoot("Projects/Booket/Resources/**")),
        .glob(pattern: .relativeToRoot("SupportingFiles/Booket/GoogleService-Info.plist")),
        .glob(pattern: .relativeToRoot("Projects/BKDesign/Resources/**")),
    ],
    entitlements: .file(path: .relativeToRoot("SupportingFiles/Booket/Booket.entitlements")),
    scripts: [
        swiftLintScript,
        crashScript
    ],
    dependencies: [
        .data(),
        .presentation(),
        .core(),
        .design(),
        .network(),
        .storage(),
        .domain(),
        .external(dependency: .Pulse),
        .external(dependency: .PulseUI),
        .external(dependency: .PulseProxy),
        .external(dependency: .FirebaseCore),
        .external(dependency: .FirebaseCrashlytics)
    ],
    settings: .settings(
        base: [
            "OTHER_LDFLAGS": ["-ObjC"],
            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
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

let releaseAppTarget = Target.target(
    name: "Reed",
    product: .app,
    bundleId: Project.bundleID,
    infoPlist: .file(path: .relativeToRoot("SupportingFiles/Booket/Info.plist")),
    sources: .sources,
    resources: [
        .glob(pattern: .relativeToRoot("Projects/Booket/Resources/**")),
        .glob(pattern: .relativeToRoot("SupportingFiles/Booket/GoogleService-Info.plist")),
        .glob(pattern: .relativeToRoot("Projects/BKDesign/Resources/**")),
    ],
    entitlements: .file(path: .relativeToRoot("SupportingFiles/Booket/Booket.entitlements")),
    scripts: [
        swiftLintScript,
        crashScript
    ],
    dependencies: [
        .data(),
        .presentation(),
        .core(),
        .design(),
        .network(),
        .storage(),
        .domain(),
        .external(dependency: .FirebaseCore),
        .external(dependency: .FirebaseCrashlytics)
    ],
    settings: .settings(
        base: [
            "OTHER_LDFLAGS": ["-ObjC"],
            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
            "DEVELOPMENT_LANGUAGE": "ko",
            "DEVELOPMENT_TEAM": "VZC79KP79S",
            "CODE_SIGN_STYLE": "Manual",
            "PROVISIONING_PROFILE_SPECIFIER": "match Development Booket.26th.yapp"
        ],
        configurations: [
            .release(name: "Release", xcconfig: .relativeToRoot("SupportingFiles/Booket/Release.xcconfig"))
        ]
    )
)

// MARK: - Project
let project = Project.project(
    name: "Booket",
    targets: [
        debugAppTarget,
        releaseAppTarget
    ],
    schemes: [
        Scheme.scheme(
            name: "Reed-Debug",
            shared: true,
            buildAction: .buildAction(targets: ["Reed-Debug"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Debug"),
            profileAction: .profileAction(configuration: "Debug"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
        Scheme.scheme(
            name: "Reed",
            shared: true,
            buildAction: .buildAction(targets: ["Reed"]),
            runAction: .runAction(configuration: "Release"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Release")
        )
    ]
)
