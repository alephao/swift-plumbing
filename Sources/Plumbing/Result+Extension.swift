extension Result {
  public func append<OtherSuccess>(
    _ other: OtherSuccess
  ) -> Result<T2<Success, OtherSuccess>, Failure> {
    self.map({ success in success .*. other })
  }

  public func append<OtherSuccess>(
    _ other: Result<OtherSuccess, Failure>
  ) -> Result<T2<Success, OtherSuccess>, Failure> {
    self.flatMap({ success in
      other.map({ otherSuccess in success .*. otherSuccess })
    })
  }

  public func prepend<OtherSuccess>(
    _ other: OtherSuccess
  ) -> Result<T2<OtherSuccess, Success>, Failure> {
    self.map({ success in other .*. success })
  }

  public func prepend<OtherSuccess>(
    _ other: Result<OtherSuccess, Failure>
  ) -> Result<T2<OtherSuccess, Success>, Failure> {
    self.flatMap({ success in
      other.map({ otherSuccess in otherSuccess .*. success })
    })
  }
}

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
