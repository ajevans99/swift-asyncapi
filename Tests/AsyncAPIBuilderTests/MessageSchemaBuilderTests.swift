import AsyncAPIBuilder
import AsyncAPIGenerator
import JSONSchema
import JSONSchemaBuilder
import Testing

@Schemable
struct ChatPayload {
  let text: String
}

struct MessageSchemaBuilderTests {
  @Test
  func buildComponents() {
    let doc = AsyncAPIDocument {
      Info(title: "Chat", version: "1.0")
      Schema(key: "ChatPayload", for: ChatPayload.self)
      Message(key: "chatMessage")
        .name("chatMessage")
        .payload(ChatPayload.self)
        .summary("A chat message")
    }

    let schema = doc.asyncapi.components?.schemas?["ChatPayload"]
    let message = doc.asyncapi.components?.messages?["chatMessage"]

    #expect(schema != nil)
    #expect(message?.name == "chatMessage")
    #expect(message?.summary == "A chat message")
  }

  @Test
  func schemableConvenience() {
    let doc = AsyncAPIDocument {
      Info(title: "Chat", version: "1.0")
      Schema(key: "ChatPayload", for: ChatPayload.self)
      Message(key: "convenient")
        .payload(ChatPayload.self)
    }

    let schema = doc.asyncapi.components?.schemas?["ChatPayload"]
    let message = doc.asyncapi.components?.messages?["convenient"]

    #expect(schema != nil)
    #expect(message?.payload != nil)
  }
}
