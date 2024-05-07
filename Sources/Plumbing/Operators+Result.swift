func alt<A, F: Error>(_ a: Result<A, F>, _ b: Result<A, F>) -> Result<A, F> {
  switch a {
  case .success(let s): return .success(s)
  case .failure: return b
  }
}

public func map<A, B, F: Error>(_ transform: @escaping (A) -> B) -> (Result<A, F>) -> Result<B, F> {
  { result in result.map(transform) }
}

public func mapError<A, F: Error, G: Error>(_ transform: @escaping (F) -> G) -> (Result<A, F>) -> Result<A, G> {
  { result in result.mapError(transform) }
}

public func mapAsync<A, B, F: Error>(_ transform: @escaping (A) async -> B) -> (Result<A, F>) async -> Result<B, F> {
  { result in
    switch result {
    case .success(let a):
      let b = await transform(a)
      return .success(b)
    case .failure(let e):
      return .failure(e)
    }
  }
}

public func mapErrorAsync<A, F: Error, G: Error>(_ transform: @escaping (F) async -> G) -> (Result<A, F>) async -> Result<A, G> {
  { result in
    switch result {
    case .success(let a): return .success(a)
    case .failure(let e):
      let g = await transform(e)
      return .failure(g)
    }
  }
}

public func flatMap<A, B, F: Error>(_ transform: @escaping (A) -> Result<B, F>) -> (Result<A, F>) -> Result<B, F> {
  { result in result.flatMap(transform) }
}

public func flatMapError<A, F: Error, G: Error>(_ transform: @escaping (F) -> Result<A, G>) -> (Result<A, F>) -> Result<A, G> {
  { result in result.flatMapError(transform) }
}

public func flatMapAsync<A, B, F: Error>(_ transform: @escaping (A) async -> Result<B, F>) -> (Result<A, F>) async -> Result<B, F> {
  { result in
    switch result {
    case .success(let a):
      return await transform(a)
    case .failure(let e):
      return .failure(e)
    }
  }
}

public func flatMapErrorAsync<A, F: Error, G: Error>(
  _ transform: @escaping (F) async -> Result<A, G>
) -> (Result<A, F>) async -> Result<A, G> {
  { result in
    switch result {
    case .success(let a): return .success(a)
    case .failure(let e):
      return await transform(e)
    }
  }
}

func <|> <A, F: Error>(_ a: Result<A, F>, _ b: Result<A, F>) -> Result<A, F> {
  alt(a, b)
}

public func >>= <A, B, F: Error>(
  _ a: Result<A, F>,
  _ transform: @escaping (A) -> Result<B, F>
) -> Result<B, F> {
  a |> flatMap(transform)
}

public func >>= <A, B, F: Error>(
  _ a: Result<A, F>,
  _ transform: @escaping (A) async -> Result<B, F>
) async -> Result<B, F> {
  await a |> flatMapAsync(transform)
}

public func >=> <A, B, C, F: Error>(
  _ f: @escaping (A) -> Result<B, F>,
  _ g: @escaping (B) -> Result<C, F>
) -> (A) -> Result<C, F> {
  f >>> flatMap(g)
}

public func >=> <A, B, C, F: Error>(
  _ f: @escaping (A) async -> Result<B, F>,
  _ g: @escaping (B) async -> Result<C, F>
) -> (A) async -> Result<C, F> {
  f >>> flatMapAsync(g)
}
