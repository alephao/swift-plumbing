import HummingbirdCore
import Plumbing

extension Bind {
  public static func decodeBody<Success, Failure, A: Decodable>(
    as decodable: A.Type,
    onError: @escaping (T2<any Error, Success>) -> AsyncResult<T2<A, Success>, Failure>
  ) -> (Success) -> AsyncResult<T2<A, Success>, Failure> {
    { success in
      .init {
        do {
          let a = try await Ctx.req.decode(as: A.self, context: Ctx.ctx)
          return .success(a .*. success)
        } catch {
          Ctx.logger.debug("[Error] decodeBody: \(String(reflecting: error))")
          return await onError(error .*. success).run()
        }
      }
    }
  }

  public static func decodeBody<Success, Failure, A: Decodable>(
    as decodable: A.Type,
    orFail fail: @escaping (Success) -> Failure
  ) -> (Success) -> AsyncResult<T2<A, Success>, Failure> {
    { success in
      .init {
        do {
          let a = try await Ctx.req.decode(as: A.self, context: Ctx.ctx)
          return .success(a .*. success)
        } catch {
          Ctx.logger.debug("[Error] decodeBody: \(String(reflecting: error))")
          return .failure(fail(success))
        }
      }
    }
  }
}
