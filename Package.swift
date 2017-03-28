import PackageDescription

let package = Package(
    name: "Meow",
    targets: [
        Target(name: "Meow"),
        Target(name: "MeowVapor", dependencies: ["Meow"]),
        Target(name: "MeowSample", dependencies: ["Meow", "MeowVapor"])
    ],
    dependencies: [
        .Package(url: "https://github.com/OpenKitten/MongoKitten.git", Version(4,0,0, prereleaseIdentifiers: ["alpha"])),
        .Package(url: "https://github.com/vapor/vapor.git", Version(2,0,0, prereleaseIdentifiers: ["beta"]))
    ]
)
