import ProjectDescription

extension Project {
    public static let bundleID = "Booket.26th.yapp"
    public static let iosVersion = "16.0"
    public static let product: Product = .staticFramework
}

extension Project {
    public static func project(
        name: String,
        targets: [Target] = [],
        schemes: [Scheme] = [],
        additionalFiles: [FileElement] = []
    ) -> Project {
        Project(
            name: name,
            targets: targets,
            schemes: schemes,
            additionalFiles: additionalFiles
        )
    }
}
