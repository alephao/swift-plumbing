import HTTPTypes
import Hummingbird
import Logging
import NIO

public struct PlumbingRequestContext: RequestContext {
  public var coreContext: CoreRequestContext

  public var requestDecoder: PlumbingRequestContext.Decoder { .init() }
  public var responseEncoder: PlumbingRequestContext.Encoder { .init() }

  public init(channel: any Channel, logger: Logger) {
    self.coreContext = .init(allocator: channel.allocator, logger: logger)
  }
}

extension PlumbingRequestContext {
  public struct Decoder: RequestDecoder {
    enum Error: Swift.Error {
      case invalidContentType
    }

    public func decode<T>(_ type: T.Type, from request: Request, context: some BaseRequestContext)
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

    public func encode(_ value: some Encodable, from request: Request, context: some BaseRequestContext)
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
