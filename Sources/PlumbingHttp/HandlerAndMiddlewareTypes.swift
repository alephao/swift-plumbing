import Hummingbird
import HummingbirdCore

public typealias PlumbingHTTPHandler = @Sendable () async -> Response
public typealias PlumbingHTTPMiddleware = (@escaping PlumbingHTTPHandler) -> PlumbingHTTPHandler

public typealias RequestHandler<Context: RequestContext> = @Sendable (Request, Context) async ->
  Response
public typealias Middleware<Context: RequestContext> = (@escaping RequestHandler<Context>) ->
  RequestHandler<Context>
