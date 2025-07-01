import AsyncAPIBuilder
import AsyncAPIGenerator
import SnapshotTesting
import Testing
import Yams

struct AsyncAPIBuilderTests {
  @Test
  func basicAsyncAPIBuild() {
    let doc = AsyncAPIDocument {
      Info(title: "Chat Service", version: "1.0.0")
        .description("AsyncAPI example")
        .tags([AsyncAPI.Tag(name: "chat")])

      Server(key: "production", url: "wss://chat.example.com/ws")
        .protocol("wss")
        .description("Production broker")

      Channel(key: "chat.message.{roomId}", address: "chat.message.{roomId}")

      // Using reference
      Operation(key: "sendMessage", action: .send)
        .channel(ref: "#/channels/chat.message.{roomId}")
        .summary("Send a message to a chat room")
        .description("Send a message to a specific chat room")
        .tags([AsyncAPI.Tag(name: "chat"), AsyncAPI.Tag(name: "message")])
        .traits(refs: ["#/components/operationTraits/kafka"])

      // Using direct value
      let channel = AsyncAPI.Channel(address: "chat.status")
      let message = AsyncAPI.Message(name: "status", payload: ["type": "string"])
      let trait = AsyncAPI.OperationTrait(
        title: "Status Operation",
        summary: "Common traits for status operations"
      )

      Operation(key: "statusUpdate", action: .receive)
        .channel(channel)
        .messages([message])
        .traits([trait])
        .summary("Receive status updates")
    }

    // Test basic properties
    let asyncapi = doc.asyncapi
    #expect(asyncapi.asyncapi == "3.0.0")
    #expect(asyncapi.info.title == "Chat Service")
    #expect(asyncapi.info.version == "1.0.0")
    #expect(asyncapi.info.description == "AsyncAPI example")
    #expect(asyncapi.info.tags?.first?.name == "chat")

    // Test server
    let server = asyncapi.servers?["production"]
    #expect(server != nil)
    #expect(server?.host == "wss://chat.example.com/ws")
    #expect(server?.protocol == "wss")
    #expect(server?.description == "Production broker")

    // Test channel
    let channel = asyncapi.channels?["chat.message.{roomId}"]
    #expect(channel != nil)
    #expect(channel?.address == "chat.message.{roomId}")

    // Test operations
    let sendMessage = asyncapi.operations?["sendMessage"]
    #expect(sendMessage != nil)
    #expect(sendMessage?.action == .send)
    #expect(sendMessage?.summary == "Send a message to a chat room")
    #expect(sendMessage?.description == "Send a message to a specific chat room")
    #expect(sendMessage?.tags?.count == 2)
    #expect(sendMessage?.tags?.first?.name == "chat")
    #expect(sendMessage?.tags?.last?.name == "message")

    let statusUpdate = asyncapi.operations?["statusUpdate"]
    #expect(statusUpdate != nil)
    #expect(statusUpdate?.action == .receive)
    #expect(statusUpdate?.summary == "Receive status updates")
  }

  @Test
  func asyncAPISnapshot() throws {
    let doc = AsyncAPIDocument {
      Info(title: "Chat Service", version: "1.0.0")
        .description("AsyncAPI example")
        .tags([AsyncAPI.Tag(name: "chat")])

      Server(key: "production", url: "wss://chat.example.com/ws")
        .protocol("wss")
        .description("Production broker")

      Channel(key: "chat.message.{roomId}", address: "chat.message.{roomId}")

      Operation(key: "sendMessage", action: .send)
        .channel(ref: "#/channels/chat.message.{roomId}")
        .summary("Send a message to a chat room")
        .description("Send a message to a specific chat room")
        .tags([AsyncAPI.Tag(name: "chat"), AsyncAPI.Tag(name: "message")])
        .traits(refs: ["#/components/operationTraits/kafka"])
    }

    let encoder = YAMLEncoder()
    encoder.options.sortKeys = true
    let yaml = try encoder.encode(doc.asyncapi)
    assertSnapshot(of: yaml, as: .init(pathExtension: "yaml", diffing: .lines))
  }

  @Test
  func runtimeRegistry() async {
    let doc = AsyncAPIDocument {
      Info(title: "Test Service", version: "1.0.0")
    }

    await RuntimeRegistry.shared.setDocument(doc.asyncapi)
    let retrieved = await RuntimeRegistry.shared.getDocument()

    #expect(retrieved != nil)
    #expect(retrieved?.info.title == "Test Service")
    #expect(retrieved?.info.version == "1.0.0")
  }

  @Test
  func channelModifiers() {
    let doc = AsyncAPIDocument {
      Info(title: "Test", version: "1.0")

      Channel(key: "c1", address: "addr")
        .title("Title")
        .summary("Sum")
        .description("Desc")
        .servers(refs: ["#/servers/s1"])
        .tags([AsyncAPI.Tag(name: "tag")])
        .externalDocs(AsyncAPI.ExternalDoc(url: "https://example.com"))
        .bindings(["kafka": ["clientId": .string("id")]])
        .messages(refs: ["m1": "#/components/messages/m1"])
        .parameters(refs: ["id": "#/components/parameters/id"])
    }

    let channel = doc.asyncapi.channels?["c1"]
    #expect(channel?.title == "Title")
    #expect(channel?.summary == "Sum")
    #expect(channel?.description == "Desc")
    var serverRef = false
    if let first = channel?.servers?.first, case .reference(let ref) = first {
      serverRef = ref == "#/servers/s1"
    }
    #expect(serverRef)
    #expect(channel?.tags?.first?.name == "tag")
    #expect(channel?.externalDocs?.url == "https://example.com")
    #expect(channel?.bindings != nil)
    var msgRef = false
    if let m = channel?.messages?["m1"], case .reference(let ref) = m {
      msgRef = ref == "#/components/messages/m1"
    }
    #expect(msgRef)
    var paramRef = false
    if let p = channel?.parameters?["id"], case .reference(let ref) = p {
      paramRef = ref == "#/components/parameters/id"
    }
    #expect(paramRef)
  }
}
