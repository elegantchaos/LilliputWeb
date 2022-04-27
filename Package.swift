// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "LilliputWeb",
    platforms: [
       .macOS(.v12)
    ],
    products: [
        .executable(
            name: "lilliweb",
            targets: ["Run"]
        ),
        .library(
            name: "LilliputWeb",
            targets: ["LilliputWeb"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Lilliput.git", from: "1.2.2"),
        .package(url: "https://github.com/elegantchaos/Runner", from: "1.0.0"),

        // 💧 Vapor.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.55.3"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.4.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.2.6"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.1.5"),
    ],
    targets: [
        .target(
            name: "LilliputWeb",
            dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "Leaf", package: "leaf"),
            .product(name: "Lilliput", package: "Lilliput"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Runner", package: "Runner")
            ],
            resources: [
                .copy("Resources/Views")
            ]
        ),
        .executableTarget(name: "Run", dependencies: [
            .target(name: "LilliputWeb"),
            .product(name: "LilliputExamples", package: "Lilliput"),
        ]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "LilliputWeb"),
            .product(name: "LilliputExamples", package: "Lilliput"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
