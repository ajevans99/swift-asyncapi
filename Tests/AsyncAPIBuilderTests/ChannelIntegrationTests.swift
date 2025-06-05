import AsyncAPIBuilder
import AsyncAPIGenerator
import Foundation
import Testing

struct ChannelIntegrationTests {
  struct ChatParams: ChannelParameterDecodable {
    let roomId: UUID
    init(from params: [String : String]) throws {
      guard let raw = params["roomId"], let uuid = UUID(uuidString: raw) else {
        throw NSError(domain: "ChannelIntegration", code: 1)
      }
      self.roomId = uuid
    }
  }

  final class RecordingBinder: TransportBinder, @unchecked Sendable {
    var records: [(server: AsyncAPI.Server, channel: AsyncAPI.Channel, action: AsyncAPI.Action)] = []
    func bind(server: AsyncAPI.Server, channel: AsyncAPI.Channel, operation: AsyncAPI.Operation, using binderContext: BinderContext) throws {
      records.append((server, channel, operation.action))
    }
  }

  @Test
  func bindInvokesTransportBinder() async throws {
    let binder = RecordingBinder()
    await BinderRegistry.shared.register("test", binder)

    let doc = AsyncAPIDocument {
      Info(title: "Chat", version: "1.0.0")
      Server(key: "local", url: "ws://localhost/chat")
        .protocol("test")

      Channel("chat.{roomId}") { ch in
        ch.parameter("roomId", ["type": "string"])
        ch.subscribe(String.self) { (_: ChatParams, _: String, _: ChannelContext) async throws in }
          .summary("sub")
        ch.publish(String.self) { _, _ in }
          .summary("pub")
      }
    }

    await RuntimeRegistry.shared.setDocument(doc.asyncapi)
    // Allow registration tasks to run
    await Task.yield()
    try await doc.asyncapi.bind(using: BinderContext())

    #expect(binder.records.count == 2)
    #expect(binder.records.first?.action == .receive)
    #expect(binder.records.last?.action == .send)
  }
}
