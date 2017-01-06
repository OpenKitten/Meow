import PackageDescription

let package = Package(
    name: "Puss",
    targets: [
        Target(name: "Puss"),
        Target(name: "PussSample", dependencies: ["Puss"])
    ],
    dependencies: [
        .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 3)
    ],
    exclude: [
        "Templates",
        "InternalTemplates"
    ]
)
