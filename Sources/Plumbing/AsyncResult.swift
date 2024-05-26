import Prelude

public struct AsyncResult<Success, Failure: Error> {
  public var run: () async -> Result<Success, Failure>

  public init(run: @escaping () async -> Result<Success, Failure>) {
    self.run = run
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

public func flatMap<A, B, F: Error>(
  _ transform: @escaping (A) -> AsyncResult<B, F>
) -> (AsyncResult<A, F>) -> AsyncResult<B, F> {
  { a in a.flatMap(transform) }
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
