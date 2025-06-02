import AsyncAPIGenerator
import Foundation
import JSONSchema
import SnapshotTesting
import Testing
import Yams

struct StreetlightsTests {
  static func createAsyncAPI() -> AsyncAPI {
    // Create info section
    let info = AsyncAPI.Info(
      title: "Streetlights Kafka API",
      version: "1.0.0",
      description: """
        The Smartylighting Streetlights API allows you to remotely manage the city
        lights.
        ### Check out its awesome features:

        * Turn a specific streetlight on/off 🌃  
        * Dim a specific streetlight 😎
        * Receive real-time information about environmental lighting conditions 📈
        """,
      license: .init(
        name: "Apache 2.0",
        url: "https://www.apache.org/licenses/LICENSE-2.0"
      )
    )

    // Create servers
    let scramServer = AsyncAPI.Server(
      host: "test.mykafkacluster.org:18092",
      title: "Test MQTT broker",
      description: "Test broker secured with scramSha256",
      protocol: "kafka-secure",
      security: [.reference("#/components/securitySchemes/saslScram")],
      tags: [
        .value(
          .init(
            name: "env:test-scram",
            descrtion: "This environment is meant for running internal tests through scramSha256"
          )
        ),
        .value(
          .init(
            name: "kind:remote",
            descrtion: "This server is a remote server. Not exposed by the application"
          )
        ),
        .value(
          .init(
            name: "visibility:private",
            descrtion: "This resource is private and only available to certain users"
          )
        ),
      ]
    )

    let mtlsServer = AsyncAPI.Server(
      host: "test.mykafkacluster.org:28092",
      title: "Test MQTT broker",
      description: "Test broker secured with X509",
      protocol: "kafka-secure",
      security: [.reference("#/components/securitySchemes/certs")],
      tags: [
        .value(
          .init(
            name: "env:test-mtls",
            descrtion: "This environment is meant for running internal tests through mtls"
          )
        ),
        .value(
          .init(
            name: "kind:remote",
            descrtion: "This server is a remote server. Not exposed by the application"
          )
        ),
        .value(
          .init(
            name: "visibility:private",
            descrtion: "This resource is private and only available to certain users"
          )
        ),
      ]
    )

    // Create channels
    let lightingMeasuredChannel = AsyncAPI.Channel(
      address: "smartylighting.streetlights.1.0.event.{streetlightId}.lighting.measured",
      description: "The topic on which measured values may be produced and consumed.",
      messages: [
        "lightMeasured": .reference("#/components/messages/lightMeasured")
      ],
      parameters: [
        "streetlightId": .reference("#/components/parameters/streetlightId")
      ]
    )

    let lightTurnOnChannel = AsyncAPI.Channel(
      address: "smartylighting.streetlights.1.0.action.{streetlightId}.turn.on",
      messages: [
        "turnOn": .reference("#/components/messages/turnOn")
      ],
      parameters: [
        "streetlightId": .reference("#/components/parameters/streetlightId")
      ]
    )

    let lightTurnOffChannel = AsyncAPI.Channel(
      address: "smartylighting.streetlights.1.0.action.{streetlightId}.turn.off",
      messages: [
        "turnOff": .reference("#/components/messages/turnOff")
      ],
      parameters: [
        "streetlightId": .reference("#/components/parameters/streetlightId")
      ]
    )

    let lightsDimChannel = AsyncAPI.Channel(
      address: "smartylighting.streetlights.1.0.action.{streetlightId}.dim",
      messages: [
        "dimLight": .reference("#/components/messages/dimLight")
      ],
      parameters: [
        "streetlightId": .reference("#/components/parameters/streetlightId")
      ]
    )

    // Create operations
    let receiveLightMeasurement = AsyncAPI.Operation(
      action: .receive,
      channel: .reference("#/channels/lightingMeasured"),
      messages: [.reference("#/components/messages/lightMeasured")],
      traits: [.reference("#/components/operationTraits/kafka")],
      title: "Receive light measurement",
      summary: "Inform about environmental lighting conditions of a particular streetlight.",
      description: "A message sent when a streetlight measurement is received."
    )

    let turnOn = AsyncAPI.Operation(
      action: .send,
      channel: .reference("#/channels/lightTurnOn"),
      messages: [.reference("#/components/messages/turnOn")],
      traits: [.reference("#/components/operationTraits/kafka")],
      title: "Turn on",
      summary: "Command a particular streetlight to turn the lights on.",
      description: "A command sent to turn the light on."
    )

    let turnOff = AsyncAPI.Operation(
      action: .send,
      channel: .reference("#/channels/lightTurnOff"),
      messages: [.reference("#/components/messages/turnOff")],
      traits: [.reference("#/components/operationTraits/kafka")],
      title: "Turn off",
      summary: "Command a particular streetlight to turn the lights off.",
      description: "A command sent to turn the light off."
    )

    let dimLight = AsyncAPI.Operation(
      action: .send,
      channel: .reference("#/channels/lightsDim"),
      messages: [.reference("#/components/messages/dimLight")],
      traits: [.reference("#/components/operationTraits/kafka")],
      title: "Dim light",
      summary: "Command a particular streetlight to dim the lights.",
      description: "A command sent to dim the lights."
    )

    // Create components
    let components = AsyncAPI.Components(
      schemas: [
        "lightMeasuredPayload": [
          "type": "object",
          "properties": [
            "lumens": [
              "type": "integer",
              "minimum": 0,
              "description": "Light intensity measured in lumens.",
            ],
            "sentAt": [
              "type": "string",
              "format": "date-time",
              "description": "Date and time when the message was sent.",
            ],
          ],
        ],
        "turnOnOffPayload": [
          "type": "object",
          "properties": [
            "command": [
              "type": "string",
              "enum": ["on", "off"],
              "description": "Whether to turn on or off the light.",
            ],
            "sentAt": [
              "type": "string",
              "format": "date-time",
              "description": "Date and time when the message was sent.",
            ],
          ],
        ],
        "dimLightPayload": [
          "type": "object",
          "properties": [
            "percentage": [
              "type": "integer",
              "description": "Percentage to which the light should be dimmed to.",
              "minimum": 0,
              "maximum": 100,
            ],
            "sentAt": [
              "type": "string",
              "format": "date-time",
              "description": "Date and time when the message was sent.",
            ],
          ],
        ],
        "sentAt": [
          "type": "string",
          "format": "date-time",
          "description": "Date and time when the message was sent.",
        ],
      ],
      messages: [
        "lightMeasured": AsyncAPI.Message(
          name: "lightMeasured",
          contentType: "application/json",
          payload: [
            "type": "object",
            "properties": [
              "lumens": [
                "type": "integer",
                "minimum": 0,
                "description": "Light intensity measured in lumens.",
              ],
              "sentAt": [
                "type": "string",
                "format": "date-time",
                "description": "Date and time when the message was sent.",
              ],
            ],
          ],
          title: "Light measured",
          summary: "Inform about environmental lighting conditions of a particular streetlight."
        ),
        "turnOnOff": AsyncAPI.Message(
          name: "turnOnOff",
          payload: [
            "type": "object",
            "properties": [
              "command": [
                "type": "string",
                "enum": ["on", "off"],
                "description": "Whether to turn on or off the light.",
              ],
              "sentAt": [
                "type": "string",
                "format": "date-time",
                "description": "Date and time when the message was sent.",
              ],
            ],
          ],
          title: "Turn on/off",
          summary: "Command a particular streetlight to turn the lights on or off."
        ),
        "dimLight": AsyncAPI.Message(
          name: "dimLight",
          payload: [
            "type": "object",
            "properties": [
              "percentage": [
                "type": "integer",
                "description": "Percentage to which the light should be dimmed to.",
                "minimum": 0,
                "maximum": 100,
              ],
              "sentAt": [
                "type": "string",
                "format": "date-time",
                "description": "Date and time when the message was sent.",
              ],
            ],
          ],
          title: "Dim light",
          summary: "Command a particular streetlight to dim the lights."
        ),
      ],
      securitySchemes: [
        "saslScram": .saslSecurityScheme(
          description: "Provide your username and password for SASL/SCRAM authentication",
          type: "scramSha256"
        ),
        "certs": .x509(
          description: "Download the certificate files from service provider"
        ),
      ],
      parameters: [
        "streetlightId": AsyncAPI.Parameter(
          description: "The ID of the streetlight."
        )
      ],
      operationTraits: [
        "kafka": AsyncAPI.OperationTrait(
          bindings: [
            "kafka": [
              "clientId": [
                "type": "string",
                "enum": ["my-app-id"],
              ]
            ]
          ]
        )
      ],
      messageTraits: [
        "commonHeaders": AsyncAPI.MessageTrait(
          headers: [
            "type": "object",
            "properties": [
              "my-app-header": [
                "type": "integer",
                "minimum": 0,
                "maximum": 100,
              ]
            ],
          ]
        )
      ]
    )

    // Create the final AsyncAPI struct
    return AsyncAPI(
      asyncapi: "3.0.0",
      info: info,
      servers: [
        "scram-connections": scramServer,
        "mtls-connections": mtlsServer,
      ],
      defaultContentType: "application/json",
      channels: [
        "lightingMeasured": lightingMeasuredChannel,
        "lightTurnOn": lightTurnOnChannel,
        "lightTurnOff": lightTurnOffChannel,
        "lightsDim": lightsDimChannel,
      ],
      operations: [
        "receiveLightMeasurement": receiveLightMeasurement,
        "turnOn": turnOn,
        "turnOff": turnOff,
        "dimLight": dimLight,
      ],
      components: components
    )
  }

  @Test
  func streetlightsYAMLSnapshot() throws {
    let asyncAPI = Self.createAsyncAPI()

    // Encode to YAML
    let encoder = YAMLEncoder()
    encoder.options.sortKeys = true
    let yaml = try encoder.encode(asyncAPI)

    // Snapshot the YAML output
    assertSnapshot(of: yaml, as: .init(pathExtension: "yaml", diffing: .lines))
  }

  @Test(
    .disabled(
      "An issue in JSONSchema related to resolving references is preventing this from working"
    )
  )
  func validateAgainstSchema() throws {
    let asyncAPI = Self.createAsyncAPI()

    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    let jsonData = try jsonEncoder.encode(asyncAPI)
    let jsonValue = try JSONDecoder().decode(JSONValue.self, from: jsonData)

    let schemaURL = try #require(
      Bundle.module.url(forResource: "3.0.0-without-$id", withExtension: "json")
    )
    let schemaData = try Data(contentsOf: schemaURL)
    let schema = try JSONDecoder().decode(Schema.self, from: schemaData)

    let result = schema.validate(jsonValue, at: .init())
    #expect(
      result.isValid,
      "AsyncAPI document failed validation: \(result.errors?.map { $0.message }.joined(separator: ", ") ?? "")"
    )
  }
}
