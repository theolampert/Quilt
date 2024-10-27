// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Quilt",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v13),
        .watchOS(.v7),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Quilt",
            targets: ["Quilt"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.99.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Quilt",
            dependencies: []
        ),
        .testTarget(
            name: "QuiltTests",
            dependencies: [
                "Quilt",
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ]
)
