// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "AbrevvaSDK",
    platforms: [
        .iOS(.v16),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "AbrevvaSDK",
            targets: ["AbrevvaSDK", "IOSDependencies"]
        ),
        .library(
            name: "AbrevvaSDKWatchOS",
            targets: ["AbrevvaSDK", "WatchOSDependencies"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", exact: "1.10.0"),
        .package(url: "https://github.com/emqx/CocoaMQTT.git", exact: "2.4.1"),
    ],
    targets: [
        .binaryTarget(name: "AbrevvaSDK", path: "AbrevvaSDK.xcframework"),
        .target(
            name: "IOSDependencies",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "CocoaMQTT", package: "CocoaMQTT"),
            ],
            path: "Sources/IOSDependencies"
        ),
        .target(
            name: "WatchOSDependencies",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift"),
            ],
            path: "Sources/WatchOSDependencies"
        ),
    ]
)
