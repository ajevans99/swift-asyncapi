import AsyncAPIGenerator
import Foundation
import InlineSnapshotTesting
import JSONSchema
import JSONSchemaBuilder
import Testing
import Yams

struct AsyncAPIGeneratorTests {
  @Test
  func minimalAsyncAPIYAML() throws {
    // Create a minimal AsyncAPI struct
    let asyncAPI = AsyncAPI(
      asyncapi: "3.0.0",
      info: .init(
        title: "Minimal API",
        version: "1.0.0"
      )
    )

    // Encode to YAML
    let encoder = YAMLEncoder()
    let yaml = try encoder.encode(asyncAPI)

    // Snapshot the YAML output
    assertInlineSnapshot(of: yaml, as: .lines) {
      """
      asyncapi: 3.0.0
      info:
        title: Minimal API
        version: 1.0.0

      """
    }
  }

  @Test
  func minimalAsyncAPIJSON() throws {
    // Create a minimal AsyncAPI struct
    let asyncAPI = AsyncAPI(
      asyncapi: "3.0.0",
      info: .init(
        title: "Minimal API",
        version: "1.0.0"
      )
    )

    // Encode to JSON
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let json = try encoder.encode(asyncAPI)
    let jsonString = String(data: json, encoding: .utf8)!

    // Snapshot the JSON output
    assertInlineSnapshot(of: jsonString, as: .lines) {
      """
      {
        "asyncapi" : "3.0.0",
        "info" : {
          "title" : "Minimal API",
          "version" : "1.0.0"
        }
      }
      """
    }
  }
}

struct MessageSchemaTests {
  @Schemable
  struct LightMeasured {
    @NumberOptions(.minimum(0))
    let lumens: Int
    let sentAt: Int
  }

  @Schemable
  struct TurnOnOff {
    @Schemable
    enum Command {
      case on, off
    }
    let command: Command
    let sentAt: Int
  }

  @Schemable
  struct DimLight {
    let percentage: Int
    let sentAt: Int
  }

  @Test
  func messageSchemasFromTypes() throws {
    // Create a minimal AsyncAPI struct with messages using @Schemable types
    let asyncAPI = AsyncAPI(
      asyncapi: "3.0.0",
      info: .init(
        title: "Message Schema Test",
        version: "1.0.0"
      ),
      components: .init(
        messages: [
          "lightMeasured": .init(
            name: "lightMeasured",
            contentType: "application/json",
            payload: LightMeasured.schema.schemaValue.value,
            title: "Light measured",
            summary: "Inform about environmental lighting conditions"
          ),
          "turnOnOff": .init(
            name: "turnOnOff",
            payload: TurnOnOff.schema.schemaValue.value,
            title: "Turn on/off",
            summary: "Command to turn the light on or off"
          ),
          "dimLight": .init(
            name: "dimLight",
            payload: DimLight.schema.schemaValue.value,
            title: "Dim light",
            summary: "Command to dim the lights"
          ),
        ]
      )
    )

    // Encode to YAML
    let encoder = YAMLEncoder()
    encoder.options.sortKeys = true
    let yaml = try encoder.encode(asyncAPI)

    // Snapshot the YAML output
    assertInlineSnapshot(of: yaml, as: .lines) {
      """
      asyncapi: 3.0.0
      components:
        messages:
          dimLight:
            name: dimLight
            payload:
              properties:
                percentage:
                  type: integer
                sentAt:
                  type: integer
              required:
              - percentage
              - sentAt
              type: object
            summary: Command to dim the lights
            title: Dim light
          lightMeasured:
            contentType: application/json
            name: lightMeasured
            payload:
              properties:
                lumens:
                  minimum: 0e+0
                  type: integer
                sentAt:
                  type: integer
              required:
              - lumens
              - sentAt
              type: object
            summary: Inform about environmental lighting conditions
            title: Light measured
          turnOnOff:
            name: turnOnOff
            payload:
              properties:
                command:
                  enum:
                  - 'on'
                  - 'off'
                  type: string
                sentAt:
                  type: integer
              required:
              - command
              - sentAt
              type: object
            summary: Command to turn the light on or off
            title: Turn on/off
      info:
        title: Message Schema Test
        version: 1.0.0

      """
    }
  }
}

extension SchemaValue {
  var value: JSONValue {
    switch self {
    case .boolean(let bool):
      return .boolean(bool)
    case .object(let dict):
      return .object(dict)
    }
  }
}
