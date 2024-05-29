import Dependencies
import Prelude
import Tuple

// ╎ ╏ ┆ ┇ ┊ ┋ │ ┃ ╽ ╿
// ╌ ╍ ┄ ┅ ┈ ┉ ─ ━ ╼ ╾
// ╻ ╷
// ╹ ╵
// ╶ ╺
// ╴ ╸
// ┌ ┍ ┎ ┏ ┓ ┒ ┑ ┐  ┬ ┭ ┮ ┯ ┰ ┱ ┲ ┳
// └ ┕ ┖ ┗ ┛ ┚ ┙ ┘  ┴ ┵ ┶ ┷ ┸ ┹ ┺ ┻
// ├ ┤ ┝ ┥ ┞ ┦ ┟ ┧ ┠ ┨ ┡ ┩ ┢ ┪ ┣ ┫
// ┽ ┾ ┿ ╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋
// ▶

// API Notes
//
// Try using same argument name in functions
// - or other: closure that returns the same type as the function return type
// - orUse use: closure that returns the success type
// - orFail fail: closure that returns the error type

// MARK: Endo - Middleware, Ensure, Effects
extension AsyncResult {
  @available(*, deprecated, message: "do not use satisfyTypes in production")
  public func satisfyTypes<
    ExpectedSuccess,
    ExpectedFailure
  >() -> AsyncResult<ExpectedSuccess, ExpectedFailure> {
    fatalError("satisfyTypes")
  }

  /// Run a transformation returning the same Success/Failure types
  ///
  /// ━[A]━━[mA]━━[A]━━▶
  public func middleware(
    run other: @escaping (Success) -> AsyncResult<Success, Failure>
  ) -> Self {
    self.flatMap(other)
  }

  /// Optionally run a transformation returning the same Success/Failure types
  ///
  ///  <true>  ┏━━[mA]━━┓
  /// ━━[A]━━━━┦        ┞━[A]━━▶
  ///  <false> └┄┄[A]┄┄┄┘
  public func middleware(
    run other: @escaping (Success) -> AsyncResult<Success, Failure>,
    if predicate: @escaping (Success) -> Bool
  ) -> Self {
    self.flatMap(Bind.middleware(run: other, if: predicate))
  }

  /// Fail with the provided closure if the predicate is not true
  ///
  /// ━━[A]━━┯━━[A]━━▶
  ///<false> └┄┄X
  public func ensure(
    _ predicate: @escaping (Success) -> Bool,
    orFail fail: @escaping (Success) -> Failure
  ) -> Self {
    self.flatMap(Bind.ensure(predicate, orFail: fail))
  }

  /// Run a non-failable effect and wait for it to finish
  ///
  ///-      ┏━[task]━┓
  /// ━[A]━━┻╍╍╍╍╍╍╍╍┻━━[A]━━▶
  public func runAndWait(
    _ task: @escaping (Success) async -> Void
  ) -> Self {
    self.flatMap(Bind.runAndWait(task))
  }

  /// Fire an effect and forget about it
  ///
  ///-      ┏╍╍[task]╍╍▶
  /// ━[A]━━┻━━[A]━━━━━▶
  public func fireAndForget(
    _ task: @escaping (Success) async -> Void
  ) -> Self {
    self.flatMap(Bind.fireAndForget(task))
  }
}

// MARK: Prepend
extension AsyncResult {
  /// Run other and prepend the result
  ///
  /// -      ┏━━[B]━━┓
  /// ━━[A]━━┻━━━━━━━┻━━[(B,A)]━━▶
  public func prepend<OtherSuccess>(
    _ other: @escaping (Success) -> AsyncResult<OtherSuccess, Failure>
  ) -> AsyncResult<T2<OtherSuccess, Success>, Failure> {
    self.flatMap(Bind.prepend(other))
  }

  /// Run other and prepend the result if the value is not nil
  ///
  /// -      ┏━[B?]━┱┄<nil>┄X
  /// ━━[A]━━┻━━━━━━┻━[(B,A)]━━▶
  public func prepend<OtherSuccess>(
    _ other: @escaping (Success) -> AsyncResult<OtherSuccess?, Failure>,
    orFail fail: @escaping (Success) -> Failure
  ) -> AsyncResult<T2<OtherSuccess, Success>, Failure> {
    self.flatMap(Bind.prepend(other, orFail: fail))
  }
}

// MARK: Fork/Switch
extension AsyncResult {
  /// Use a predicate to decide which transformation to use
  ///
  /// <true>  ┌┄┄[tB]┄┄┐
  /// ━[A]━━━━┪        ┢━━[B]━━▶
  /// <false> ┗━━[fB]━━┛
  public func fork<NewSuccess>(
    predicate: @escaping (Success) -> Bool,
    ifTrue: @escaping (Success) -> AsyncResult<NewSuccess, Failure>,
    ifFalse: @escaping (Success) -> AsyncResult<NewSuccess, Failure>
  ) -> AsyncResult<NewSuccess, Failure> {
    self.flatMap(Bind.fork(predicate: predicate, ifTrue: ifTrue, ifFalse: ifFalse))
  }

  /// Switch to a different pipeline
  /// Constraint: Success == Failure
  ///
  /// ━[A]━━━┱┄┄[A]┄┄┄▶
  ///      <true>
  ///        ┗━━[A']━━▶
  public func `switch`(
    to other: @escaping (Success) -> AsyncResult<Success, Failure>,
    if predicate: @escaping (Success) -> Bool
  ) -> Self where Success == Failure {
    self.flatMap(Bind.switch(to: other, if: predicate))
  }
}

// MARK: Unwrap
extension AsyncResult {
  /// Unwraps an optional success value or fails with the provided closure
  /// Constraint: Success is Optional
  ///
  /// ━[A?]━┯━[A]━━▶
  ///     <nil>
  ///       X
  public func unwrap<Wrapped>(
    orFail fail: @escaping () -> Failure
  ) -> AsyncResult<Wrapped, Failure> where Success == Wrapped? {
    self.flatMap(Bind.unwrap(orFail: fail))
  }

  /// Unwraps an optional or run a pipeline that returns an unwrapped value
  /// Constraint: Success is Optional
  ///
  /// ━[A?]━┱┄┄[A]┄┄┄┐
  ///     <nil>      ┢━[A]━━▶
  ///       ┗━━[A']━━┛
  public func unwrap<Wrapped>(
    or other: @escaping () -> AsyncResult<Wrapped, Failure>
  ) -> AsyncResult<Wrapped, Failure> where Success == Wrapped? {
    self.flatMap(Bind.unwrap(or: other))
  }

  /// Unwraps an optional property or fails with the provided closure
  ///
  /// -    ┏━[B?]━┱┄<nil>┄X
  /// ━[A]━┻━━━━━━┻━[B,A]━━▶
  public func unwrap<Property>(
    property: @escaping (Success) -> Property?,
    orFail fail: @escaping (Success) -> Failure
  ) -> AsyncResult<T2<Property, Success>, Failure> {
    self.flatMap(Bind.unwrap(property: property, orFail: fail))
  }

  /// Run a closure depending if the property was successfuly uwrapped
  ///
  /// TODO: Drawing
  public func unwrapFork<Property, NewSuccess>(
    property: @escaping (Success) -> Property?,
    some: @escaping (T2<Property, Success>) -> AsyncResult<NewSuccess, Failure>,
    none: @escaping (Success) -> AsyncResult<NewSuccess, Failure>
  ) -> AsyncResult<NewSuccess, Failure> {
    self.flatMap(Bind.unwrapFork(property: property, some: some, none: none))
  }
}

// MARK: Parallel
extension AsyncResult {
  /// Run a and b in parallel
  ///
  ///-      ┏━━[A]━━┓
  /// ━[S]━━╋━━━━━━━╋━[S,A,B]━━▶
  ///       ┗━━[B]━━┛
  public func parallel<A, B>(
    a: @escaping (Success) -> AsyncResult<A, Failure>,
    b: @escaping (Success) -> AsyncResult<B, Failure>
  ) -> AsyncResult<T3<Success, A, B>, Failure> {
    self.flatMap(Bind.parallel(a: a, b: b))
  }

  /// Run a, b, and c in parallel
  ///
  ///-      ┏━━[A]━━┓
  ///       ┣━━[B]━━┫
  /// ━[S]━━╋━━━━━━━╋━[S,A,B,C]━━▶
  ///       ┗━━[C]━━┛
  public func parallel<A, B, C>(
    a: @escaping (Success) -> AsyncResult<A, Failure>,
    b: @escaping (Success) -> AsyncResult<B, Failure>,
    c: @escaping (Success) -> AsyncResult<C, Failure>
  ) -> AsyncResult<T4<Success, A, B, C>, Failure> {
    self.flatMap(Bind.parallel(a: a, b: b, c: c))
  }

  /// Run a, b, c, and d in parallel
  ///
  ///-      ┏━━[A]━━┓
  ///       ┣━━[B]━━┫
  /// ━[S]━━╋━━━━━━━╋━[S,A,B,C,D]━━▶
  ///       ┣━━[C]━━┫
  ///       ┗━━[D]━━┛
  public func parallel<A, B, C, D>(
    a: @escaping (Success) -> AsyncResult<A, Failure>,
    b: @escaping (Success) -> AsyncResult<B, Failure>,
    c: @escaping (Success) -> AsyncResult<C, Failure>,
    d: @escaping (Success) -> AsyncResult<D, Failure>
  ) -> AsyncResult<T5<Success, A, B, C, D>, Failure> {
    self.flatMap(Bind.parallel(a: a, b: b, c: c, d: d))
  }
}
