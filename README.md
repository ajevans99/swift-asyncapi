# Swift AsyncAPI Generator

[![CI](https://github.com/ajevans99/swift-asyncapi/actions/workflows/ci.yml/badge.svg)](https://github.com/ajevans99/swift-asyncapi/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fajevans99%2Fswift-asyncapi%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ajevans99/swift-asyncapi)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fajevans99%2Fswift-asyncapi%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ajevans99/swift-asyncapi)

A Swift library for generating [AsyncAPI](https://www.asyncapi.com) documents.

> [!IMPORTANT]
> Work in progress.

## Usage

### Basic Example

```swift
import AsyncAPIGenerator
import JSONSchemaBuilder

// Define your message types
@Schemable
struct LightMeasured {
    @NumberOptions(.minimum(0))
    let lumens: Int
    let sentAt: Int
}

// Create an AsyncAPI document
let asyncAPI = AsyncAPI(
    asyncapi: "3.0.0",
    info: .init(
        title: "Streetlights API",
        version: "1.0.0"
    ),
    components: .init(
        messages: [
            "lightMeasured": .init(
                name: "lightMeasured",
                contentType: "application/json",
                payload: LightMeasured.jsonSchema,
                title: "Light measured",
                summary: "Inform about environmental lighting conditions"
            )
        ]
    )
)

// Encode to JSON
let encoder = JSONEncoder()
let json = try encoder.encode(asyncAPI)
```

`AsyncAPI` conforms to `Codable`. You can use [Yams](https://github.com/jpsim/Yams) to encode to yaml.

See the full [Streetlights test](Tests/AsyncAPIGeneratorTests/StreetlightsTests.swift) for a full example.

### Supported Features

- Message definitions
- Server configurations
- Channel definitions
- Operation definitions
- Security schemes
- Components
- Tags and external documentation

## Documentation

Documentation available through [SPI here](https://swiftpackageindex.com/ajevans99/swift-asyncapi/main/documentation/asyncapigenerator)

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ajevans99/swift-asyncapi.git", from: "0.1.0")
]
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Links

- [AsyncAPI Specification](https://www.asyncapi.com)
- [swift-json-schema](https://github.com/ajevans99/swift-json-schema)
- [Yams](https://github.com/jpsim/Yams)
