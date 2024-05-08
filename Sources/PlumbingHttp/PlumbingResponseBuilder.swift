import Plumbing
import Foundation
import Hummingbird

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct PlumbingResponderBuilder: HTTPResponderBuilder {
  public let handler: PlumbingHTTPHandler

  public init(handler: @escaping PlumbingHTTPHandler) {
    self.handler = handler
  }

  public func buildResponder() -> PlumbingResponder {
    PlumbingResponder(handler: handler)
  }
}

public struct PlumbingResponder: HTTPResponder {
  public typealias Context = PlumbingRequestContext

  public let handler: PlumbingHTTPHandler

  public init(handler: @escaping PlumbingHTTPHandler) {
    self.handler = handler
  }

  public func respond(
    to request: Request,
    context: PlumbingRequestContext
  ) async -> Response {
    let ctx = PlumbingHttp.Context(req: request, ctx: context, logger: context.logger)
    return await PlumbingHttp.Context.$value.withValue(ctx) {
      await handler()
    }
  }
}
