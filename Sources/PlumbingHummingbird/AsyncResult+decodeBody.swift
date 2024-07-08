import Dependencies
import HummingbirdCore
import Plumbing

extension Bind {
  public static func decodeBody<Success, A: Decodable>(
    as decodable: A.Type,
    onError: @escaping (T2<any Error, Success>) -> AsyncResult<T2<A, Success>, Response>
  ) -> (Success) -> AsyncResult<T2<A, Success>, Response> {
    { success in
      .init {
        @Dependency(\.req) var req
        @Dependency(\.ctx) var ctx
        do {
          let a = try await ctx.requestDecoder.decode(A.self, from: req, context: ctx)
          return .success(a .*. success)
        } catch {
          ctx.logger.debug("[Error] decodeBody: \(String(reflecting: error))")
          return await onError(error .*. success).run()
        }
      }
    }
  }

  public static func decodeBody<Success, A: Decodable>(
    as decodable: A.Type,
    orFail fail: @escaping (Success) -> Response
  ) -> (Success) -> AsyncResult<T2<A, Success>, Response> {
    { success in
      .init {
        @Dependency(\.req) var req
        @Dependency(\.ctx) var ctx
        do {
          let a = try await ctx.requestDecoder.decode(A.self, from: req, context: ctx)
          return .success(a .*. success)
        } catch {
          ctx.logger.debug("[Error] decodeBody: \(String(reflecting: error))")
          return .failure(fail(success))
        }
      }
    }
  }
}

extension AsyncResult where Failure == Response {
  public func decodeBody<A: Decodable>(
    as decodable: A.Type,
    onError: @escaping (T2<any Error, Success>) -> AsyncResult<T2<A, Success>, Response>
  ) -> AsyncResult<T2<A, Success>, Response> {
    self.flatMap(Bind.decodeBody(as: decodable, onError: onError))
  }

  public func decodeBody<A: Decodable>(
    as decodable: A.Type,
    orFail fail: @escaping (Success) -> Response
  ) -> AsyncResult<T2<A, Success>, Response> {
    self.flatMap(Bind.decodeBody(as: decodable, orFail: fail))
  }
}

public func decodeBody<Success, A: Decodable>(
  as decodable: A.Type,
  onError: @escaping (T2<any Error, Success>) -> AsyncResult<T2<A, Success>, Response>
) -> (AsyncResult<Success, Response>) -> AsyncResult<T2<A, Success>, Response> {
  { r in r.decodeBody(as: decodable, onError: onError) }
}

public func decodeBody<Success, A: Decodable>(
  as decodable: A.Type,
  orFail fail: @escaping (Success) -> Response
) -> (AsyncResult<Success, Response>) -> AsyncResult<T2<A, Success>, Response> {
  { r in r.decodeBody(as: decodable, orFail: fail) }
}
