import Plumbing

import struct HummingbirdCore.Response

extension Action {
  public static func decodeBody<Input, Output, T: Decodable>(
    as decodable: T.Type,
    map _map: @escaping (T, Input) -> Output,
    or respond: @escaping (any Error, Input) -> Response
  ) -> (Input) async -> Swift.Result<Output, Response> {
    { input in
      do {
        let t = try await Ctx.req.decode(as: T.self, context: Ctx.ctx)
        return .success(_map(t, input))
      } catch {
        Ctx.logger.debug("Action.decodeBody: \(String(reflecting: error))")
        return .failure(respond(error, input))
      }
    }
  }
}
