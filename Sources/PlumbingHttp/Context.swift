import Hummingbird
import Logging

public struct Context {
  public let req: Request
  public let ctx: PlumbingRequestContext
  public let logger: Logger

  @TaskLocal
  static var value: Self!
}

public enum Ctx {
  public static var req: Request { Context.value.req }
  public static var ctx: PlumbingRequestContext { Context.value.ctx }
  public static var logger: Logger { Context.value.logger }
}
