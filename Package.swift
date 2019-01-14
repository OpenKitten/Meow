// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Meow",
    products: [
        .library(name: "Meow", targets: ["Meow"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "Meow", dependencies: ["MongoKitten"]),
        .testTarget(name: "MeowTests", dependencies: ["Meow"]),
    ]
)
