// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription

let package = Package(
    name: "Meow",
    dependencies: [
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", .revision("async")),
        
        // For Swift 4.0-development-2017-06-19
        .package(url: "https://github.com/OpenKitten/BSON.git", .revision("29e51865ce352e83351932fe41c65ddc3254a447")),
        .package(url: "https://github.com/OpenKitten/Cheetah.git", .branch("swift4")),
        
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
