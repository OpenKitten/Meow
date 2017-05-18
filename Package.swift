import PackageDescription

let package = Package(
    name: "Meow",
    targets: [
        Target(name: "Meow")
    ],
    dependencies: [
       .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 4)
    ]
)
