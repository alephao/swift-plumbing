import struct HummingbirdCore.Request
import struct HummingbirdCore.Response

public typealias Handler = @Sendable (Request, PlumbingRequestContext) async -> Response
