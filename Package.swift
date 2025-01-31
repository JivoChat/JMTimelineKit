// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "JMTimelineKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "JMTimelineKit",
            targets: ["JMTimelineKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/DenTelezhkin/DTCollectionViewManager.git", from: "11.0.0"),
        .package(url: "https://github.com/JivoChat/JMOnetimeCalculator.git", exact: "2.0.0"),
        .package(url: "https://github.com/JivoChat/SwiftyNSException.git", exact: "2.0.0"),
    ],
    targets: [
        .target(
            name: "JMTimelineKit",
            dependencies: [
                .product(name: "DTCollectionViewManager", package: "DTCollectionViewManager"),
                .product(name: "JMOnetimeCalculator", package: "JMOnetimeCalculator"),
                .product(name: "SwiftyNSException", package: "SwiftyNSException"),
            ],
            path: "JMTimelineKit"
        )
    ]
)
