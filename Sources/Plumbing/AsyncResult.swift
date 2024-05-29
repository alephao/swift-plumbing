import Prelude

public struct AsyncResult<Success, Failure: Error> {
  public var run: () async -> Result<Success, Failure>

  public init(run: @escaping () async -> Result<Success, Failure>) {
    self.run = run
  }

  public init(try f: @escaping () async throws -> Success) where Failure == any Error {
    self.run = {
      do {
        let success = try await f()
        return .success(success)
      } catch {
        return .failure(error)
      }
    }
  }

  public init(result: Result<Success, Failure>) {
    self.run = { result }
  }

  public static func success(_ value: Success) -> Self {
    Self { .success(value) }
  }

  public static func failure(_ error: Failure) -> Self {
    Self { .failure(error) }
  }

  public static func pure(_ success: Success) -> AsyncResult<Success, Failure> {
    .success(success)
  }

  public func map<NewSuccess>(
    _ transform: @escaping (Success) -> NewSuccess
  ) -> AsyncResult<NewSuccess, Failure> {
    .init {
      switch await run() {
      case let .success(success): return .success(transform(success))
      case let .failure(error): return .failure(error)
      }
    }
  }

  public func mapError<NewFailure: Error>(
    _ transform: @escaping (Failure) -> NewFailure
  ) -> AsyncResult<Success, NewFailure> {
    .init {
      switch await run() {
      case let .success(success): return .success(success)
      case let .failure(error): return .failure(transform(error))
      }
    }
  }

  public func bimap<NewSuccess, NewFailure: Error>(
    success _map: @escaping (Success) -> NewSuccess,
    failure _mapError: @escaping (Failure) -> NewFailure
  ) -> AsyncResult<NewSuccess, NewFailure> {
    self.map(_map).mapError(_mapError)
  }

  public func flatMap<NewSuccess>(
    _ transform: @escaping (Success) -> AsyncResult<NewSuccess, Failure>
  ) -> AsyncResult<NewSuccess, Failure> {
    .init {
      switch await run() {
      case let .success(success): return await transform(success).run()
      case let .failure(error): return .failure(error)
      }
    }
  }

  public func flatMapError<NewFailure: Error>(
    _ transform: @escaping (Failure) -> AsyncResult<Success, NewFailure>
  ) -> AsyncResult<Success, NewFailure> {
    .init {
      switch await run() {
      case let .success(success): return .success(success)
      case let .failure(error): return await transform(error).run()
      }
    }
  }

  public func flatMap<NewSuccess, NewFailure: Error>(
    success _flatMap: @escaping (Success) -> AsyncResult<NewSuccess, NewFailure>,
    failure _flatMapError: @escaping (Failure) -> AsyncResult<NewSuccess, NewFailure>
  ) -> AsyncResult<NewSuccess, NewFailure> {
    .init {
      switch await self.run() {
      case .success(let success): return await _flatMap(success).run()
      case .failure(let failure): return await _flatMapError(failure).run()
      }
    }
  }

  public func or(
    _ other: @escaping @autoclosure () -> AsyncResult<Success, Failure>
  ) -> AsyncResult<Success, Failure> {
    flatMapError({ _ in other() })
  }

  public func apply<NewSuccess>(
    _ f: AsyncResult<(Success) -> NewSuccess, Failure>
  ) -> AsyncResult<NewSuccess, Failure> {
    f.flatMap(map)
  }
}

extension AsyncResult {
  public static func wrapFunc<Input>(
    _ f: @escaping (Input) async -> Result<Success, Failure>
  ) -> (Input)
    -> AsyncResult<Success, Failure>
  {
    { input in
      .init {
        await f(input)
      }
    }
  }
}

extension AsyncResult {
  public static func <¢> <NewSuccess>(
    f: @escaping (Success) -> NewSuccess,
    x: AsyncResult<Success, Failure>
  ) -> AsyncResult<NewSuccess, Failure> {
    return x.map(f)
  }
}

extension AsyncResult: Alt {
  public static func <|> (
    lhs: AsyncResult,
    rhs: @autoclosure @escaping () -> AsyncResult
  ) -> AsyncResult {
    lhs.or(rhs())
  }
}

public func map<Success, NewSuccess, Failure: Error>(
  _ transform: @escaping (Success) -> NewSuccess
) -> (AsyncResult<Success, Failure>) -> AsyncResult<NewSuccess, Failure> {
  { a in a.map(transform) }
}

public func mapError<Success, Failure: Error, NewFailure: Error>(
  _ transform: @escaping (Failure) -> NewFailure
) -> (AsyncResult<Success, Failure>) -> AsyncResult<Success, NewFailure> {
  { a in a.mapError(transform) }
}

public func flatMap<A, B, F: Error>(
  _ transform: @escaping (A) -> AsyncResult<B, F>
) -> (AsyncResult<A, F>) -> AsyncResult<B, F> {
  { a in a.flatMap(transform) }
}

public func flatMapError<Success, Failure: Error, NewFailure: Error>(
  _ transform: @escaping (Failure) -> AsyncResult<Success, NewFailure>
) -> (AsyncResult<Success, Failure>) -> AsyncResult<Success, NewFailure> {
  { a in a.flatMapError(transform) }
}

public func >>= <A, B, F: Error>(
  _ a: AsyncResult<A, F>,
  _ transform: @escaping (A) -> AsyncResult<B, F>
) -> AsyncResult<B, F> {
  a.flatMap(transform)
}

public func >=> <A, B, C, F: Error>(
  _ f: @escaping (A) -> AsyncResult<B, F>,
  _ g: @escaping (B) -> AsyncResult<C, F>
) -> (A) -> AsyncResult<C, F> {
  { a in f(a).flatMap(g) }
}
