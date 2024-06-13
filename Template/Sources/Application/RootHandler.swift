import Dependencies
import Plumbing
import PlumbingHummingbird
import Router

import struct Hummingbird.Request
import struct Hummingbird.Response

@Sendable func rootHandler(req: Request, ctx: PlumbingRequestContext) async -> Response {
  @Dependency(\.route) var route
  let responseResult = await render(route: route).run()
  return responseResult.either()
}
