import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: BKModule.BKDesign.rawValue,
    targets: [
        Target.target(
            name: BKModule.BKDesign.rawValue,
            product: Project.product,
            bundleId: "design." + Project.bundleID,
            sources: .sources,
            resources: .default,
            scripts: [
                swiftLintScript
            ],
            dependencies: [
                .core(),
                .external(dependency: .SnapKit)
            ]
        ),
        Target.target(
            name: "BKDesignPreviewApp",
            product: .app,
            bundleId: "designpreview." + Project.bundleID,
            infoPlist: .file(path: .relativeToRoot("Projects/BKDesign/PreviewApp/Info.plist")), // 복사본!
            sources: ["PreviewApp/Sources/**"],
            resources: [
                "PreviewApp/Resources/**",
                .glob(pattern: .relativeToRoot("Projects/BKDesign/Resources/Font/**"))
            ],
            scripts: [
                swiftLintScript
            ],
            dependencies: [
                .design() // BKDesign 모듈 의존성
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_LANGUAGE": "ko",
                    "CODE_SIGN_STYLE": "Automatic" // 미리보기 앱은 자동으로
                ],
                configurations: [
                    .debug(name: "Debug", xcconfig: .relativeToRoot("SupportingFiles/Booket/Debug.xcconfig")),
                ]
            )
        )
        
        
    ]
)

