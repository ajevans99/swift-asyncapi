import AsyncAPIBuilder
import AsyncAPIGenerator
import Testing

struct BinderRegistryTests {
  struct DummyBinder: TransportBinder {
    func bind(server: AsyncAPI.Server, channel: AsyncAPI.Channel, operation: AsyncAPI.Operation, using binderContext: BinderContext) throws {
    }
  }

  @Test
  func registerAndLookupBinder() async {
    let binder = DummyBinder()
    await BinderRegistry.shared.register("ws", binder)
    let retrieved = await BinderRegistry.shared.binder(for: "ws")
    #expect(retrieved != nil)
  }
}
