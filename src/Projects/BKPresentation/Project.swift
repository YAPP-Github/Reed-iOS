import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: BKModule.BKPresentation.rawValue,
    targets: [
        Target.target(
            name: BKModule.BKPresentation.rawValue,
            product: Project.product,
            bundleId: "presentation." + Project.bundleID,
            sources: .sources,
            scripts: [
                swiftLintScript
            ],
            dependencies: [
                .core(),
                .domain(),
                .design(),
                .external(dependency: .SnapKit)
            ]
        ),
        Target.target(
            name: "\(BKModule.BKPresentation.rawValue)Test",
            product: .unitTests,
            bundleId: "presentationtest" + Project.bundleID,
            sources: .tests,
            dependencies: [
                .presentation()
            ]
        )
    ]
)
