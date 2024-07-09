import Foundation
import Hummingbird
import Logging
import NIOCore

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct PlumbingRequestContext: RequestContext {
  public var coreContext: CoreRequestContextStorage

  public var requestDecoder: PlumbingRequestContext.Decoder { .init() }
  public var responseEncoder: PlumbingRequestContext.Encoder { .init() }

  public init(source: some RequestContextSource) {
    self.coreContext = .init(source: source)
  }
}

extension PlumbingRequestContext {
  public struct Decoder: RequestDecoder {
    enum Error: Swift.Error {
      case invalidContentType
    }

    public func decode<T>(_ type: T.Type, from request: Request, context: some RequestContext)
      async throws -> T where T: Decodable
    {
      switch request.headers[values: .contentType].first {
      case "application/json":
        return try await JSONDecoder().decode(type, from: request, context: context)
      case "application/x-www-form-urlencoded":
        return try await URLEncodedFormDecoder().decode(type, from: request, context: context)
      default:
        throw Error.invalidContentType
      }
    }
  }

  public struct Encoder: ResponseEncoder {
    enum Error: Swift.Error {
      case invalidContentType
    }

    public func encode(
      _ value: some Encodable,
      from request: Request,
      context: some RequestContext
    )
      throws -> Response
    {
      switch request.headers[values: .contentType].first {
      case "application/json":
        return try JSONEncoder().encode(value, from: request, context: context)
      case "application/x-www-form-urlencoded":
        return try URLEncodedFormEncoder().encode(value, from: request, context: context)
      default:
        throw Error.invalidContentType
      }
    }
  }
}
