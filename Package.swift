import PackageDescription

let package = Package(
    name: "Meow",
    targets: [
        Target(name: "Meow"),
        Target(name: "MeowSample", dependencies: ["Meow"]),
//        Target(name: "MeowVapor", dependencies: ["Meow"]),
        Target(name: "MeowVaporSample", dependencies: ["MeowVapor"])
    ],
    dependencies: [
       .Package(url: "https://github.com/OpenKitten/MongoKitten.git", Version(0,0,28)),
//       .Package(url: "https://github.com/vapor/vapor.git", Version(2,0,0, prereleaseIdentifiers: ["beta"])),
    ]
)
