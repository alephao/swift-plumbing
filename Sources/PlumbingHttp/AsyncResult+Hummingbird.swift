import HummingbirdCore
import Plumbing

extension AsyncResult {
  public func decodeBody<A: Decodable>(
    as decodable: A.Type,
    onError: @escaping (T2<any Error, Success>) -> AsyncResult<T2<A, Success>, Failure>
  ) -> AsyncResult<T2<A, Success>, Failure> {
    self.flatMap({ success in
      .init {
        do {
          let a = try await Ctx.req.decode(as: A.self, context: Ctx.ctx)
          return .success(a .*. success)
        } catch {
          Ctx.logger.debug("[Error] decodeBody: \(String(reflecting: error))")
          return await onError(error .*. success).run()
        }
      }
    })
  }

  public func decodeBody<A: Decodable>(
    as decodable: A.Type,
    orFail: @escaping (Success) -> Failure
  ) -> AsyncResult<T2<A, Success>, Failure> {
    self.flatMap({ success in
      .init {
        do {
          let a = try await Ctx.req.decode(as: A.self, context: Ctx.ctx)
          return .success(a .*. success)
        } catch {
          Ctx.logger.debug("[Error] decodeBody: \(String(reflecting: error))")
          return .failure(orFail(success))
        }
      }
    })
  }
}
