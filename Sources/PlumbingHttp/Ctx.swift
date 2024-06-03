import Dependencies
import HummingbirdCore
import Logging

public enum Ctx {
  public static var req: Request {
    @Dependency(\.req) var req
    return req
  }
  public static var ctx: PlumbingRequestContext {
    @Dependency(\.ctx) var ctx
    return ctx
  }
  public static var logger: Logger {
    @Dependency(\.logger) var logger
    return logger
  }
}
