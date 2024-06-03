import Dependencies
import Foundation
import Hummingbird
import Plumbing

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
    return await withDependencies { deps in
      deps.req = request
      deps.ctx = context
    } operation: {
      return await handler()
    }
  }
}
