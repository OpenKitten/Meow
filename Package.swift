import PackageDescription

let package = Package(
    name: "Meow",
    targets: [
        Target(name: "Meow"),
        Target(name: "MeowVapor", dependencies: ["Meow"]),
        Target(name: "MeowSample", dependencies: ["Meow", "MeowVapor"])
    ],
    dependencies: [
        .Package(url: "https://github.com/OpenKitten/MongoKitten.git", "4.0.0-alpha.2"),
        .Package(url: "https://github.com/vapor/vapor.git", "2.0.0-beta.1")
    ]
)
