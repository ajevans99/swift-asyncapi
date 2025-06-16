import AsyncAPIBuilder
import AsyncAPIGenerator
import Foundation
import Testing

struct ChannelDSLTests {
  struct RoomParams: ChannelParameterDecodable {
    let id: UUID
    init(from params: [String: String]) throws {
      guard let raw = params["id"], let uuid = UUID(uuidString: raw) else {
        throw NSError(domain: "ChannelDSL", code: 1)
      }
      self.id = uuid
    }
  }

  @Test
  func channelBuilderRegistersOperations() async {
    let doc = AsyncAPIDocument {
      Channel("chat.{id}") { ch in
        ch.parameter("id", ["type": "string"])
        ch.subscribe(String.self) { (_: RoomParams, _: String, _: ChannelContext) async throws in
        }
        ch.publish(String.self) { _, _ in }
      }
    }

    await RuntimeRegistry.shared.setDocument(doc.asyncapi)
    // Yield to allow registration tasks to complete
    await Task.yield()
    let runtime = await RuntimeRegistry.shared.operationRuntime(for: "chat.{id}-0")
    #expect(runtime != nil)
    #expect(doc.asyncapi.operations?.count == 2)
  }
}
