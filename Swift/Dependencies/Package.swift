// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dependencies",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Dependencies",
            targets: ["Dependencies"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0")
      .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.6.0"),
      .package(url: "https://github.com/mxcl/PromiseKit.git", from: "4.5.1"),
      .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
      .package(url: "https://github.com/ReactiveKit/ReactiveKit.git", from: "3.8.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Dependencies",
            dependencies: ["Alamofire", "PromiseKit", "SwiftyJSON", "ReactiveKit"]),
        .testTarget(
            name: "DependenciesTests",
            dependencies: ["Dependencies"]),
    ]
)
