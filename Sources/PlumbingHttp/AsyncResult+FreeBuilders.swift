import HummingbirdCore
import Plumbing

public func decodeBody<Success, Failure, A: Decodable>(
  as decodable: A.Type,
  onError: @escaping (T2<any Error, Success>) -> AsyncResult<T2<A, Success>, Failure>
) -> (AsyncResult<Success, Failure>) -> AsyncResult<T2<A, Success>, Failure> {
  { r in r.decodeBody(as: decodable, onError: onError) }
}

public func decodeBody<Success, Failure, A: Decodable>(
  as decodable: A.Type,
  orFail fail: @escaping (Success) -> Failure
) -> (AsyncResult<Success, Failure>) -> AsyncResult<T2<A, Success>, Failure> {
  { r in r.decodeBody(as: decodable, orFail: fail) }
}
