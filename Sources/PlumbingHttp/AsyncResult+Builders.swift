import HummingbirdCore
import Plumbing

extension AsyncResult {
  public func decodeBody<A: Decodable>(
    as decodable: A.Type,
    onError: @escaping (T2<any Error, Success>) -> AsyncResult<T2<A, Success>, Failure>
  ) -> AsyncResult<T2<A, Success>, Failure> {
    self.flatMap(Bind.decodeBody(as: decodable, onError: onError))
  }

  public func decodeBody<A: Decodable>(
    as decodable: A.Type,
    orFail fail: @escaping (Success) -> Failure
  ) -> AsyncResult<T2<A, Success>, Failure> {
    self.flatMap(Bind.decodeBody(as: decodable, orFail: fail))
  }
}
