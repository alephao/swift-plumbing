import Dependencies
import Prelude

public enum Bind {
  @available(*, deprecated, message: "do not use satisfyTypes in production")
  public func satisfyTypes<
    Success,
    ExpectedSuccess,
    ExpectedFailure
  >() -> (Success) -> AsyncResult<
    ExpectedSuccess, ExpectedFailure
  > {
    fatalError("satisfyTypes")
  }

  public static func middleware<Success, Failure>(
    run other: @escaping (Success) -> AsyncResult<Success, Failure>
  ) -> (Success) -> AsyncResult<Success, Failure> {
    { success in
      return other(success)
    }
  }

  public static func middleware<Success, Failure>(
    run other: @escaping (Success) -> AsyncResult<Success, Failure>,
    if predicate: @escaping (Success) -> Bool
  ) -> (Success) -> AsyncResult<Success, Failure> {
    { success in
      if predicate(success) {
        return other(success)
      }
      return .success(success)
    }
  }

  public static func ensure<Success, Failure>(
    _ predicate: @escaping (Success) -> Bool,
    orFail fail: @escaping (Success) -> Failure
  ) -> (Success) -> AsyncResult<Success, Failure> {
    middleware(run: fail >>> AsyncResult.failure, if: not <<< predicate)
  }

  public static func runAndWait<Success, Failure>(
    _ task: @escaping (Success) async -> Void
  ) -> (Success) -> AsyncResult<Success, Failure> {
    { success in
      .init {
        await task(success)
        return .success(success)
      }
    }
  }

  public static func fireAndForget<Success, Failure>(
    _ task: @escaping (Success) async -> Void
  ) -> (Success) -> AsyncResult<Success, Failure> {
    { success in
      .init {
        @Dependency(\.fireAndForget) var fnf
        await fnf {
          await task(success)
        }
        return .success(success)
      }
    }
  }

  public static func prepend<Success, Failure, OtherSuccess>(
    _ other: @escaping (Success) -> AsyncResult<OtherSuccess, Failure>
  ) -> (Success) -> AsyncResult<T2<OtherSuccess, Success>, Failure> {
    { success in
      other(success).map({ otherSuccess in otherSuccess .*. success })
    }
  }

  public static func prepend<Success, Failure, OtherSuccess>(
    _ other: @escaping (Success) -> AsyncResult<OtherSuccess?, Failure>,
    orFail fail: @escaping (Success) -> Failure
  ) -> (Success) -> AsyncResult<T2<OtherSuccess, Success>, Failure> {
    { success in
      other(success)
        .flatMap({ otherSuccess in
          switch otherSuccess {
          case .none:
            return .failure(fail(success))
          case let .some(otherSuccessUnwrapped):
            return .success(otherSuccessUnwrapped .*. success)
          }
        })
    }
  }

  public static func fork<Success, Failure, NewSuccess>(
    predicate: @escaping (Success) -> Bool,
    ifTrue: @escaping (Success) -> AsyncResult<NewSuccess, Failure>,
    ifFalse: @escaping (Success) -> AsyncResult<NewSuccess, Failure>
  ) -> (Success) -> AsyncResult<NewSuccess, Failure> {
    { success in
      return predicate(success)
        ? ifTrue(success)
        : ifFalse(success)
    }
  }

  public static func `switch`<Success>(
    to other: @escaping (Success) -> AsyncResult<Success, Success>,
    if predicate: @escaping (Success) -> Bool
  ) -> (Success) -> AsyncResult<Success, Success> {
    { success in
      if predicate(success) {
        return AsyncResult {
          let res = await other(success).run()
          return .failure(res.either())
        }
      }
      return .success(success)
    }
  }

  public static func unwrap<Wrapped, Failure>(
    orFail fail: @escaping () -> Failure
  ) -> (Wrapped?) -> AsyncResult<Wrapped, Failure> {
    { wrapped in
      if let unwrapped = wrapped {
        return .success(unwrapped)
      }
      return .failure(fail())
    }
  }

  public static func unwrap<Wrapped, Failure>(
    or other: @escaping () -> AsyncResult<Wrapped, Failure>
  ) -> (Wrapped?) -> AsyncResult<Wrapped, Failure> {
    { wrapped in
      if let unwrapped = wrapped {
        return .success(unwrapped)
      }
      return other()
    }
  }

  public static func unwrap<Success, Failure, Property>(
    property: @escaping (Success) -> Property?,
    orFail fail: @escaping (Success) -> Failure
  ) -> (Success) -> AsyncResult<T2<Property, Success>, Failure> {
    { success in
      if let unwrapped = property(success) {
        return .success(unwrapped .*. success)
      }
      return .failure(fail(success))
    }
  }

  public static func unwrapFork<Success, Failure, Property, NewSuccess>(
    property: @escaping (Success) -> Property?,
    some: @escaping (T2<Property, Success>) -> AsyncResult<NewSuccess, Failure>,
    none: @escaping (Success) -> AsyncResult<NewSuccess, Failure>
  ) -> (Success) -> AsyncResult<NewSuccess, Failure> {
    { success in
      if let unwrapped = property(success) {
        return some(unwrapped .*. success)
      }
      return none(success)
    }
  }

  public static func parallel<Success, Failure, A, B>(
    a: @escaping (Success) -> AsyncResult<A, Failure>,
    b: @escaping (Success) -> AsyncResult<B, Failure>
  ) -> (Success) -> AsyncResult<T3<Success, A, B>, Failure> {
    { success in
      AsyncResult {
        // TODO: Do not wait for both if one fails first
        async let _a = a(success).run()
        async let _b = b(success).run()
        let (resA, resB) = await (_a, _b)
        return
          resB
          .prepend(resA)
          .prepend(success)
      }
    }
  }

  public static func parallel<Success, Failure, A, B, C>(
    a: @escaping (Success) -> AsyncResult<A, Failure>,
    b: @escaping (Success) -> AsyncResult<B, Failure>,
    c: @escaping (Success) -> AsyncResult<C, Failure>
  ) -> (Success) -> AsyncResult<T4<Success, A, B, C>, Failure> {
    { success in
      AsyncResult {
        // TODO: Do not wait for both if one fails first
        async let _a = a(success).run()
        async let _b = b(success).run()
        async let _c = c(success).run()
        let (resA, resB, resC) = await (_a, _b, _c)
        return
          resC
          .prepend(resB)
          .prepend(resA)
          .prepend(success)
      }
    }
  }

  public static func parallel<Success, Failure, A, B, C, D>(
    a: @escaping (Success) -> AsyncResult<A, Failure>,
    b: @escaping (Success) -> AsyncResult<B, Failure>,
    c: @escaping (Success) -> AsyncResult<C, Failure>,
    d: @escaping (Success) -> AsyncResult<D, Failure>
  ) -> (Success) -> AsyncResult<T5<Success, A, B, C, D>, Failure> {
    { success in
      AsyncResult {
        // TODO: Do not wait for both if one fails first
        async let _a = a(success).run()
        async let _b = b(success).run()
        async let _c = c(success).run()
        async let _d = d(success).run()
        let (resA, resB, resC, resD) = await (_a, _b, _c, _d)
        return
          resD
          .prepend(resC)
          .prepend(resB)
          .prepend(resA)
          .prepend(success)
      }
    }
  }
}
