// swift-tools-version: 6.0
@preconcurrency import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: [
            "KakaoSDK": .staticLibrary,
            "Nimble": .framework,
            "Quick": .framework,
            "SnapKit": .staticLibrary,
            "Kingfisher": .framework
        ]
    )
#endif

let package = Package(
    name: "src",
    dependencies: [
        .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.23.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.7.1"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "8.5.0")
    ]
)
