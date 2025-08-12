import ProjectDescription
import ProjectDescriptionHelpers

let appTarget = Target.target(
    name: "Reed",
    product: .app,
    bundleId: Project.bundleID,
    infoPlist: .extendingDefault(with: [
        "BASE_API_URL": .string("${BASE_API_URL}"),
        "ITSAppUsesNonExemptEncryption" : false,
        "KAKAO_NATIVE_APP_KEY": .string("${KAKAO_NATIVE_APP_KEY}"),
        "UILaunchStoryboardName": .string("LaunchScreen"),
        "CFBundleURLTypes": .array([
            .dictionary([
                "CFBundleTypeRole": .string("Editor"),
                "CFBundleURLSchemes": .array([.string("kakao${KAKAO_NATIVE_APP_KEY}")])
            ])
        ]),
        "LSApplicationQueriesSchemes": .array([
            .string("kakaokompassauth"),
            .string("kakaolink"),
            .string("kakaoplus")
        ]),
        "NSCameraUsageDescription": .string("OCR을 통해 텍스트를 인식하여 더 편리한 문장 입력 방식을 제공하기 위해서 카메라를 사용합니다."),
        "UIAppFonts": .array([
            .string("Pretendard-SemiBold.otf"),
            .string("Pretendard-Regular.otf"),
            .string("Pretendard-Medium.otf"),
            .string("Pretendard-Bold.otf")
        ]),
        "UIApplicationSceneManifest": .dictionary([
            "UIApplicationSupportsMultipleScenes": .boolean(false),
            "UISceneConfigurations": .dictionary([
                "UIWindowSceneSessionRoleApplication": .array([
                    .dictionary([
                        "UISceneClassName": .string("UIWindowScene"),
                        "UISceneConfigurationName": .string("Default Configuration"),
                        "UISceneDelegateClassName": .string("Reed.SceneDelegate")
                    ])
                ])
            ])
        ]),
        "UISupportedInterfaceOrientations": .array([
            .string("UIInterfaceOrientationPortrait")
        ])
    ]),
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

// MARK: - Project
let project = Project.project(
    name: "Booket",
    targets: [
        appTarget
    ]
)
