extension Result where Success == Failure {
  public func either() -> Success {
    switch self {
    case .success(let s): return s
    case .failure(let f): return f
    }
  }
}

public func either<S: Error>(_ result: Result<S, S>) -> S {
  result.either()
}
