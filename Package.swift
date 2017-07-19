// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription

let package = Package(
    name: "Meow",
    dependencies: [
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", .revision("async")),
        
        // For Swift 4.0-development-2017-06-19
        .package(url: "https://github.com/OpenKitten/BSON.git", .revision("framework")),
        .package(url: "https://github.com/OpenKitten/Cheetah.git", .branch("framework")),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Meow",
            dependencies: ["MongoKitten"]),
        .testTarget(
            name: "MeowTests",
            dependencies: ["Meow"]),
    ]
)
