import Hummingbird
import Logging

public struct Context {
  public let req: Request
  public let ctx: PlumbingRequestContext
  public let logger: Logger

  @TaskLocal
  static var value: Self!
}

public var Ctx: Context {
  Context.value
}
