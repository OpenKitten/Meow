// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Meow",
    products: [
        .library(name: "Meow", targets: ["Meow"]),
    ],
    dependencies: [
       .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "4.1.0")
    ],
    targets: [
        .target(name: "Meow", dependencies: ["MongoKitten"]),
        .testTarget(name: "MeowTests", dependencies: ["Meow"]),
    ]
)
