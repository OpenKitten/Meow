import PackageDescription

let package = Package(
    name: "Meow",
    targets: [
        Target(name: "Meow"),
        Target(name: "MeowSample", dependencies: ["Meow"])
    ],
    dependencies: [
       .Package(url: "https://github.com/OpenKitten/MongoKitten.git", Version(0,0,30))
    ]
)
