import PackageDescription

let package = Package(
    name: "Meow",
    targets: [
        Target(name: "Meow"),
        Target(name: "MeowVapor", dependencies: ["Meow"]),
        Target(name: "MeowSample", dependencies: ["Meow", "MeowVapor"])
    ],
    dependencies: [
        .Package(url: "https://github.com/OpenKitten/MongoKitten.git", Version(0,0,19)),
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5)
    ]
)
