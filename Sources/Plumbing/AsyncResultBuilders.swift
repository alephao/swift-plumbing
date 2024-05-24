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

// MARK: Middleware
extension AsyncResult {
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
  /// ━━[A]━━━━┦        ┞━[A]━▶
  ///  <false> └┄┄[A]┄┄┄┘
  public func middleware(
    run other: @escaping (Success) -> AsyncResult<Success, Failure>,
    if predicate: @escaping (Success) -> Bool
  ) -> Self {
    self.flatMap({ success in
      if predicate(success) {
        return other(success)
      }
      return .success(success)
    })
  }
}

// Fork/Switch
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
    self.flatMap({ success in
      return predicate(success)
        ? ifTrue(success)
        : ifFalse(success)
    })
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
    .init {
      switch await run() {
      case let .success(success):
        return predicate(success)
          ? .failure(success)
          : .success(success)
      case let .failure(failure): return .failure(failure)
      }
    }
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
    orFail other: @escaping () -> Failure
  ) -> AsyncResult<Wrapped, Failure> where Success == Wrapped? {
    self.flatMap({ wrapped in
      if let unwrapped = wrapped {
        return .success(unwrapped)
      }
      return .failure(other())
    })
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
    self.flatMap({ wrapped in
      if let unwrapped = wrapped {
        return .success(unwrapped)
      }
      return other()
    })
  }
}

extension AsyncResult {
  /// Run a and b in parallel
  ///
  ///-      ┏━━[A]━━┓
  /// ━[S]━━╋━━━━━━━╋━[(S,A,B)]━━▶
  ///       ┗━━[B]━━┛
  public func parallel<A, B>(
    a: @escaping (Success) -> AsyncResult<A, Failure>,
    b: @escaping (Success) -> AsyncResult<B, Failure>
  ) -> AsyncResult<T3<Success, A, B>, Failure> {
    .init {
      switch await run() {
      case let .success(success):
        // TODO: Do not wait for both if one fails first
        async let _a = a(success).run()
        async let _b = b(success).run()
        let (resA, resB) = await (_a, _b)
        return
          resB
          .prepend(resA)
          .prepend(success)
      case let .failure(failure): return .failure(failure)
      }
    }
  }

  /// Run a, b, and c in parallel
  ///
  ///-      ┏━━[A]━━┓
  ///       ┣━━[B]━━┫
  /// ━[S]━━╋━━━━━━━╋━[t(S,A,B,C)]━━▶
  ///       ┗━━[C]━━┛
  public func parallel<A, B, C>(
    a: @escaping (Success) -> AsyncResult<A, Failure>,
    b: @escaping (Success) -> AsyncResult<B, Failure>,
    c: @escaping (Success) -> AsyncResult<C, Failure>
  ) -> AsyncResult<T4<Success, A, B, C>, Failure> {
    .init {
      switch await run() {
      case let .success(success):
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
      case let .failure(failure): return .failure(failure)
      }
    }
  }

  /// Run a, b, c, and d in parallel
  ///
  ///-      ┏━━[A]━━┓
  ///       ┣━━[B]━━┫
  /// ━[S]━━╋━━━━━━━╋━[t(S,A,B,C,D)]━━▶
  ///       ┣━━[C]━━┫
  ///       ┗━━[D]━━┛
  public func parallel<A, B, C, D>(
    a: @escaping (Success) -> AsyncResult<A, Failure>,
    b: @escaping (Success) -> AsyncResult<B, Failure>,
    c: @escaping (Success) -> AsyncResult<C, Failure>,
    d: @escaping (Success) -> AsyncResult<D, Failure>
  ) -> AsyncResult<T5<Success, A, B, C, D>, Failure> {
    .init {
      switch await run() {
      case let .success(success):
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
      case let .failure(failure): return .failure(failure)
      }
    }
  }
}
