import ProjectDescription

extension Target {
    public static func target(
        name: String,
        product: Product,
        bundleId: String? = nil,
        infoPlist: InfoPlist? = .default,
        sources: SourceFilesList? = nil,
        resources: ResourceFileElements? = nil,
        entitlements: Entitlements? = nil,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil
    ) -> Target {
        Target.target(
            name: name,
            destinations: .init([.iPhone]),
            product: product,
            bundleId: bundleId ?? Project.bundleID + "." + name.lowercased(),
            deploymentTargets: .iOS(Project.iosVersion),
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            scripts: scripts,
            dependencies: dependencies,
            settings: settings
        )
    }
}

extension SourceFilesList {
    public static let sources: SourceFilesList = ["Sources/**"]
    
    public static let tests: SourceFilesList = ["Tests/**"]
}
