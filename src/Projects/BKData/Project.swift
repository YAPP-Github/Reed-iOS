import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: BKModule.BKData.rawValue,
    targets: [
        Target.target(
            name: BKModule.BKData.rawValue,
            product: Project.product,
            bundleId: "data." + Project.bundleID,
            sources: .sources,
            scripts: [
                swiftLintScript
            ],
            dependencies: [
                .core(),
                .domain(),
                .external(dependency: .KakaoSDKCommon),
                .external(dependency: .KakaoSDKAuth),
                .external(dependency: .KakaoSDKUser),
                .external(dependency: .FirebaseRemoteConfig)
            ]
        ),
        Target.target(
            name: "\(BKModule.BKData.rawValue)Test",
            product: .unitTests,
            bundleId: "datatest" + Project.bundleID,
            sources: .tests,
            dependencies: [
                .data(),
                .external(dependency: .Nimble),
                .external(dependency: .Quick)
            ]
        )
    ]
)
