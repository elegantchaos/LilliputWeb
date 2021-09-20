// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LilliputWeb",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "Run",
            targets: ["Run"]
        ),
        .library(
            name: "LilliputWeb",
            targets: ["LilliputWeb"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Lilliput.git", from: "1.2.1"),

        // 💧 Vapor.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.44.1"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.2.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.1.1"),
    ],
    targets: [
        .target(
            name: "LilliputWeb",
            dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Leaf", package: "leaf"),
            .product(name: "Lilliput", package: "Lilliput"),
            ],
            resources: [
                .copy("Resources/Views")
            ]
        ),
        .target(name: "Run", dependencies: [
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
