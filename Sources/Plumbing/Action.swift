public enum Action {}
public typealias A = Action

// MARK: - Builders
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

// MARK: - Short-Circuit
extension Action {
  public static func `switch`<Input, Failure: Error>(
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

  public static func `switch`<Input, OtherActionInput, Failure: Error>(
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