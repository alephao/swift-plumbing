import Tuple

// MARK: Endo - Middleware, Ensure, Effects

/// Run a transformation returning the same Success/Failure types
///
/// ━[A]━━[mA]━━[A]━━▶
public func middleware<Success, Failure: Error>(
  run other: @escaping (Success) -> AsyncResult<Success, Failure>
) -> (AsyncResult<Success, Failure>) -> AsyncResult<Success, Failure> {
  { r in r.middleware(run: other) }
}

/// Optionally run a transformation returning the same Success/Failure types
///
///  <true>  ┏━━[mA]━━┓
/// ━━[A]━━━━┦        ┞━[A]━━▶
///  <false> └┄┄[A]┄┄┄┘
public func middleware<Success, Failure>(
  run other: @escaping (Success) -> AsyncResult<Success, Failure>,
  if predicate: @escaping (Success) -> Bool
) -> (AsyncResult<Success, Failure>) -> AsyncResult<Success, Failure> {
  { r in r.middleware(run: other, if: predicate) }
}

/// Fail with the provided closure if the predicate is not true
///
/// ━━[A]━━┯━━[A]━━▶
///<false> └┄┄X
public func ensure<Success, Failure>(
  _ predicate: @escaping (Success) -> Bool,
  orFail fail: @escaping (Success) -> Failure
) -> (AsyncResult<Success, Failure>) -> AsyncResult<Success, Failure> {
  { r in r.ensure(predicate, orFail: fail) }
}

/// Run a non-failable effect and wait for it to finish
///
///-      ┏━[task]━┓
/// ━[A]━━┻╍╍╍╍╍╍╍╍┻━━[A]━━▶
public func runAndWait<Success, Failure>(
  _ task: @escaping (Success) async -> Void
) -> (AsyncResult<Success, Failure>) -> AsyncResult<Success, Failure> {
  { r in r.runAndWait(task) }
}

/// Fire an effect and forget about it
///
///-      ┏╍╍[task]╍╍▶
/// ━[A]━━┻━━[A]━━━━━▶
public func fireAndForget<Success, Failure>(
  _ task: @escaping (Success) async -> Void
) -> (AsyncResult<Success, Failure>) -> AsyncResult<Success, Failure> {
  { r in r.fireAndForget(task) }
}

// MARK: Prepend

/// Run other and prepend the result
///
/// -      ┏━━[B]━━┓
/// ━━[A]━━┻━━━━━━━┻━━[(B,A)]━━▶
public func prepend<Success, Failure, OtherSuccess>(
  _ other: @escaping (Success) -> AsyncResult<OtherSuccess, Failure>
) -> (AsyncResult<Success, Failure>) -> AsyncResult<T2<OtherSuccess, Success>, Failure> {
  { r in r.prepend(other) }
}

/// Run other and prepend the result if the value is not nil
///
/// -      ┏━[B?]━┱┄<nil>┄X
/// ━━[A]━━┻━━━━━━┻━[(B,A)]━━▶
public func prepend<Success, Failure, OtherSuccess>(
  _ other: @escaping (Success) -> AsyncResult<OtherSuccess?, Failure>,
  orFail: @escaping (Success) -> Failure
) -> (AsyncResult<Success, Failure>) -> AsyncResult<T2<OtherSuccess, Success>, Failure> {
  { r in r.prepend(other, orFail: orFail) }
}

// MARK: Fork/Switch
/// Use a predicate to decide which transformation to use
///
/// <true>  ┌┄┄[tB]┄┄┐
/// ━[A]━━━━┪        ┢━━[B]━━▶
/// <false> ┗━━[fB]━━┛
public func fork<Success, Failure, NewSuccess>(
  predicate: @escaping (Success) -> Bool,
  ifTrue: @escaping (Success) -> AsyncResult<NewSuccess, Failure>,
  ifFalse: @escaping (Success) -> AsyncResult<NewSuccess, Failure>
) -> (AsyncResult<Success, Failure>) -> AsyncResult<NewSuccess, Failure> {
  { r in r.fork(predicate: predicate, ifTrue: ifTrue, ifFalse: ifFalse) }
}

/// Switch to a different pipeline
/// Constraint: Success == Failure
///
/// ━[A]━━━┱┄┄[A]┄┄┄▶
///      <true>
///        ┗━━[A']━━▶
public func `switch`<Success>(
  to other: @escaping (Success) -> AsyncResult<Success, Success>,
  if predicate: @escaping (Success) -> Bool
) -> (AsyncResult<Success, Success>) -> AsyncResult<Success, Success> {
  { r in r.switch(to: other, if: predicate) }
}

// MARK: Unwrap

/// Unwraps an optional success value or fails with the provided closure
/// Constraint: Success is Optional
///
/// ━[A?]━┯━[A]━━▶
///     <nil>
///       X
public func unwrap<Wrapped, Failure>(
  orFail other: @escaping () -> Failure
) -> (AsyncResult<Wrapped?, Failure>) -> AsyncResult<Wrapped, Failure> {
  { r in r.unwrap(orFail: other) }
}

/// Unwraps an optional or run a pipeline that returns an unwrapped value
/// Constraint: Success is Optional
///
/// ━[A?]━┱┄┄[A]┄┄┄┐
///     <nil>      ┢━[A]━━▶
///       ┗━━[A']━━┛
public func unwrap<Wrapped, Failure>(
  or other: @escaping () -> AsyncResult<Wrapped, Failure>
) -> (AsyncResult<Wrapped?, Failure>) -> AsyncResult<Wrapped, Failure> {
  { r in r.unwrap(or: other) }
}

// MARK: Parallel
/// Run a and b in parallel
///
///-      ┏━━[A]━━┓
/// ━[S]━━╋━━━━━━━╋━[(S,A,B)]━━▶
///       ┗━━[B]━━┛
public func parallel<Success, Failure, A, B>(
  a: @escaping (Success) -> AsyncResult<A, Failure>,
  b: @escaping (Success) -> AsyncResult<B, Failure>
) -> (AsyncResult<Success, Failure>) -> AsyncResult<T3<Success, A, B>, Failure> {
  { r in r.parallel(a: a, b: b) }
}

/// Run a, b, and c in parallel
///
///-      ┏━━[A]━━┓
///       ┣━━[B]━━┫
/// ━[S]━━╋━━━━━━━╋━[t(S,A,B,C)]━━▶
///       ┗━━[C]━━┛
public func parallel<Success, Failure, A, B, C>(
  a: @escaping (Success) -> AsyncResult<A, Failure>,
  b: @escaping (Success) -> AsyncResult<B, Failure>,
  c: @escaping (Success) -> AsyncResult<C, Failure>
) -> (AsyncResult<Success, Failure>) -> AsyncResult<T4<Success, A, B, C>, Failure> {
  { r in r.parallel(a: a, b: b, c: c) }
}

/// Run a, b, c, and d in parallel
///
///-      ┏━━[A]━━┓
///       ┣━━[B]━━┫
/// ━[S]━━╋━━━━━━━╋━[t(S,A,B,C,D)]━━▶
///       ┣━━[C]━━┫
///       ┗━━[D]━━┛
public func parallel<Success, Failure, A, B, C, D>(
  a: @escaping (Success) -> AsyncResult<A, Failure>,
  b: @escaping (Success) -> AsyncResult<B, Failure>,
  c: @escaping (Success) -> AsyncResult<C, Failure>,
  d: @escaping (Success) -> AsyncResult<D, Failure>
) -> (AsyncResult<Success, Failure>) -> AsyncResult<T5<Success, A, B, C, D>, Failure> {
  { r in r.parallel(a: a, b: b, c: c, d: d) }
}
