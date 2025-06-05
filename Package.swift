// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "swift-asyncapi",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .watchOS(.v10),
    .tvOS(.v17),
    .macCatalyst(.v17),
    .visionOS(.v1),
  ],
  products: [
    .library(
      name: "AsyncAPIGenerator",
      targets: ["AsyncAPIGenerator"]
    ),
    .library(
      name: "AsyncAPIBuilder",
      targets: ["AsyncAPIBuilder"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/ajevans99/swift-json-schema.git", from: "0.5.1"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.16.0"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "6.0.0"),
  ],
  targets: [
    .target(
      name: "AsyncAPIGenerator",
      dependencies: [
        .product(name: "JSONSchema", package: "swift-json-schema"),
        .product(name: "JSONSchemaBuilder", package: "swift-json-schema"),
      ]
    ),
    .target(
      name: "AsyncAPIBuilder",
      dependencies: [
        "AsyncAPIGenerator"
      ]
    ),
    .testTarget(
      name: "AsyncAPIGeneratorTests",
      dependencies: [
        "AsyncAPIGenerator",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "Yams", package: "Yams"),
      ],
      exclude: [
        "__Snapshots__"
      ],
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "AsyncAPIBuilderTests",
      dependencies: [
        "AsyncAPIBuilder",
        "AsyncAPIGenerator",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "Yams", package: "Yams"),
      ]
    ),
  ]
)
