import AsyncAPIBuilder
import AsyncAPIGenerator
import JSONSchemaBuilder
import Testing

@Schemable
struct PingPayload {
  let msg: String
}

struct OperationMessageBuilderTests {
  @Test
  func operationWithMessageBuilder() {
    let doc = AsyncAPIDocument {
      Info(title: "Test", version: "1.0")
      Operation(key: "ping", action: .send)
        .channel(AsyncAPI.Channel(address: "ping"))
        .messages([
          Message(key: "pingMsg")
            .payload(PingPayload.self)
        ])
    }

    let op = doc.asyncapi.operations?["ping"]
    var payloadExists = false
    if let first = op?.messages?.first, case .value(let value) = first {
      payloadExists = value.payload != nil
    }
    #expect(payloadExists)
    #expect(doc.asyncapi.components?.messages?["pingMsg"] == nil)
  }
}
