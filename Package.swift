// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
let package = Package(
    name: "AdelsonApiCaller",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "AdelsonApiCaller",
            targets: ["AdelsonApiCaller"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")),
        .package(url: "https://github.com/Ahmed23Adel/AdelsonAuthManager", branch: "master"),
        .package(url: "https://github.com/Ahmed23Adel/AdelsonValidator", branch: "main"),
    ],
    targets: [
        .target(
            name: "AdelsonApiCaller",
            dependencies: ["Alamofire","AdelsonAuthManager","AdelsonValidator"]
        ),
        .testTarget(
            name: "AdelsonApiCallerTests",
            dependencies: ["AdelsonApiCaller"]
        ),
    ]
)
