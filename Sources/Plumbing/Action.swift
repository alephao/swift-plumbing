public enum Action {}
public typealias A = Action

// MARK: - Result
extension Action {
  public static func run<
    Input,
    OutputSuccess,
    OutputFailure: Error,
    ActionInput,
    ActionSuccess,
    ActionFailure: Error
  >(
    _ action: @escaping (ActionInput) async -> Result<ActionSuccess, ActionFailure>,
    mapInput: @escaping (Input) -> ActionInput,
    flatMap _flatMap: @escaping (ActionSuccess, Input) -> Result<OutputSuccess, OutputFailure>,
    flatMapError _flatMapError: @escaping (ActionFailure, Input) -> Result<
      OutputSuccess, OutputFailure
    >
  ) -> (Input) async -> Result<OutputSuccess, OutputFailure> {
    { input in
      let result = await action(mapInput(input))
      switch result {
      case .success(let s): return _flatMap(s, input)
      case .failure(let e): return _flatMapError(e, input)
      }
    }
  }

  public static func run<
    Input,
    OutputSuccess,
    OutputFailure: Error,
    ActionInput,
    ActionSuccess,
    ActionFailure: Error
  >(
    _ action: @escaping (ActionInput) async -> Result<ActionSuccess, ActionFailure>,
    mapInput: @escaping (Input) -> ActionInput,
    map _map: @escaping (ActionSuccess, Input) -> OutputSuccess,
    mapError _mapError: @escaping (ActionFailure, Input) -> OutputFailure
  ) -> (Input) async -> Result<OutputSuccess, OutputFailure> {
    { input in
      let result = await action(mapInput(input))
      switch result {
      case .success(let s): return .success(_map(s, input))
      case .failure(let e): return .failure(_mapError(e, input))
      }
    }
  }

  public static func run<
    Input,
    OutputSuccess,
    OutputFailure: Error,
    ActionSuccess,
    ActionFailure: Error
  >(
    _ action: @escaping (Input) async -> Result<ActionSuccess, ActionFailure>,
    flatMap _flatMap: @escaping (ActionSuccess, Input) -> Result<OutputSuccess, OutputFailure>,
    flatMapError _flatMapError: @escaping (ActionFailure, Input) -> Result<
      OutputSuccess, OutputFailure
    >
  ) -> (Input) async -> Result<OutputSuccess, OutputFailure> {
    run(
      action,
      mapInput: id,
      flatMap: _flatMap,
      flatMapError: _flatMapError
    )
  }

  public static func run<
    Input,
    OutputSuccess,
    OutputFailure: Error,
    ActionSuccess,
    ActionFailure: Error
  >(
    _ action: @escaping (Input) async -> Result<ActionSuccess, ActionFailure>,
    map _map: @escaping (ActionSuccess, Input) -> OutputSuccess,
    mapError _mapError: @escaping (ActionFailure, Input) -> OutputFailure
  ) -> (Input) async -> Result<OutputSuccess, OutputFailure> {
    run(
      action,
      mapInput: id,
      map: _map,
      mapError: _mapError
    )
  }
}

// MARK: Throwable
extension Action {
  public static func run<
    Input,
    OutputSuccess,
    OutputFailure: Error,
    ActionInput,
    ActionSuccess
  >(
    _ action: @escaping (ActionInput) async throws -> ActionSuccess,
    mapInput: @escaping (Input) -> ActionInput,
    flatMap _flatMap: @escaping (ActionSuccess, Input) -> Result<OutputSuccess, OutputFailure>,
    flatMapError _flatMapError: @escaping (any Error, Input) -> Result<
      OutputSuccess, OutputFailure
    >
  ) -> (Input) async -> Result<OutputSuccess, OutputFailure> {
    { input in
      do {
        let success = try await action(mapInput(input))
        return _flatMap(success, input)
      } catch {
        return _flatMapError(error, input)
      }
    }
  }

  public static func run<
    Input,
    OutputSuccess,
    OutputFailure: Error,
    ActionInput,
    ActionSuccess
  >(
    _ action: @escaping (ActionInput) async throws -> ActionSuccess,
    mapInput: @escaping (Input) -> ActionInput,
    map _map: @escaping (ActionSuccess, Input) -> OutputSuccess,
    mapError _mapError: @escaping (any Error, Input) -> OutputFailure
  ) -> (Input) async -> Result<OutputSuccess, OutputFailure> {
    { input in
      do {
        let success = try await action(mapInput(input))
        return .success(_map(success, input))
      } catch {
        return .failure(_mapError(error, input))
      }
    }
  }
}

// MARK: - Middleware
extension Action {
  public static func middleware<Input, Failure: Error>(
    to otherAction: @escaping (Input) async -> Result<Input, Failure>,
    when predicate: @escaping (Input) -> Bool
  ) -> (Input) async -> Result<Input, Failure> {
    { input in
      if predicate(input) {
        return await otherAction(input)
      }
      return .success(input)
    }
  }

  public static func middleware<Input, OtherActionInput, Failure: Error>(
    to otherAction: @escaping (OtherActionInput) async -> Result<Input, Failure>,
    whenUnwrapped unwrap: @escaping (Input) -> OtherActionInput?
  ) -> (Input) async -> Result<Input, Failure> {
    { input in
      if let unwrapped = unwrap(input) {
        return await otherAction(unwrapped)
      }
      return .success(input)
    }
  }
}

// MARK: - Unwrap
extension Action {
  static func unwrap<Input, Failure: Error>(
    orFail fail: @escaping () -> Failure
  ) -> (Input?) async -> Result<Input, Failure> {
    { input in
      guard let input else {
        return .failure(fail())
      }
      return .success(input)
    }
  }

  static func unwrap<Input, Failure: Error>(
    orUse alternative: @escaping () -> Input
  ) -> (Input?) async -> Result<Input, Failure> {
    { input in
      guard let input else {
        return .success(alternative())
      }
      return .success(input)
    }
  }
}

// MARK: - Fallback
// I guess people call it "choose" instead of fallback, but fallback sounds more intuitive IMO
extension Action {
  public static func fallback<Input, Success, Failure: Error>(
    _ a: @escaping (Input) async -> Result<Success, Failure>,
    _ b: @escaping (Input) async -> Result<Success, Failure>
  ) -> (Input) async -> Result<Success, Failure> {
    { input in
      let resultA = await a(input)
      switch resultA {
      case .success(let s): return .success(s)
      case .failure:
        return await b(input)
      }
    }
  }

  public static func fallback<Input, Success, Failure: Error>(
    _ a: @escaping (Input) async -> Result<Success, Failure>,
    _ b: @escaping (Input) async -> Result<Success, Failure>,
    _ c: @escaping (Input) async -> Result<Success, Failure>
  ) -> (Input) async -> Result<Success, Failure> {
    fallback(fallback(a, b), c)
  }

  public static func fallback<Input, Success, Failure: Error>(
    _ a: @escaping (Input) async -> Result<Success, Failure>,
    _ b: @escaping (Input) async -> Result<Success, Failure>,
    _ c: @escaping (Input) async -> Result<Success, Failure>,
    _ d: @escaping (Input) async -> Result<Success, Failure>
  ) -> (Input) async -> Result<Success, Failure> {
    fallback(fallback(a, b, c), d)
  }
}
