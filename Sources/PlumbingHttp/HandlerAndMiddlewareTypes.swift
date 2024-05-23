import HummingbirdCore

public typealias PlumbingHTTPHandler = @Sendable () async -> Response
public typealias PlumbingHTTPMiddleware = (@escaping PlumbingHTTPHandler) -> PlumbingHTTPHandler
