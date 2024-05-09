import struct HummingbirdCore.Response

public typealias PlumbingHTTPHandler = @Sendable () async -> Response
public typealias PlumbingHTTPMiddleware = (@escaping PlumbingHTTPHandler) -> PlumbingHTTPHandler
