import Plumbing
import Foundation
import Hummingbird

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct PlumbingResponderBuilder: HTTPResponderBuilder {
  public let middleware: @Sendable () async -> Response

  public init(middleware: @Sendable @escaping () async -> Response) {
    self.middleware = middleware
  }

  public func buildResponder() -> PlumbingResponder {
    PlumbingResponder(middleware: middleware)
  }
}

public struct PlumbingResponder: HTTPResponder {
  public typealias Context = PlumbingRequestContext

  public let middleware: @Sendable () async -> Response

  public init(middleware: @Sendable @escaping () async -> Response) {
    self.middleware = middleware
  }

  public func respond(
    to request: Request,
    context: PlumbingRequestContext
  ) async -> Response {
    let ctx = PlumbingHttp.Context(req: request, ctx: context, logger: context.logger)
    return await PlumbingHttp.Context.$value.withValue(ctx) {
      await loggerMiddleware(middleware)()
    }
  }
}
private func loggerMiddleware(_ middleware: @Sendable @escaping () async -> Response) -> () async -> Response {
  return {
    // TODO: Use mockable uuid
    let req = Ctx.req
    let ctx = Ctx.ctx
    let logger = Ctx.logger

    let requestID = UUID()
    let startTime = Date().timeIntervalSince1970
    logger.log(
      level: .info,
      """
      \(requestID) [Req] \(req.method) \
      \(req.uri.path)
      """
    )
    let res = await middleware()
    let endTime = Date().timeIntervalSince1970
    logger.log(
      level: .info,
      "\(requestID) [Res] \(res.status.code) in \(Int((endTime - startTime) * 1000))ms"
    )
    return res
  }
}
