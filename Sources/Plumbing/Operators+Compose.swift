public func >>> <A, B, C>(
  _ a2b: @escaping (A) -> B,
  _ b2c: @escaping (B) -> C
) -> (A) -> C {
  { a in b2c(a2b(a)) }
}

public func <<< <A, B, C>(
  _ b2c: @escaping (B) -> C,
  _ a2b: @escaping (A) -> B
) -> (A) -> C {
  return { a in b2c(a2b(a)) }
}

public func >>> <A, B, C>(
  _ a2b: @escaping (A) async -> B,
  _ b2c: @escaping (B) async -> C
) -> (A) async -> C {
  { a in await b2c(a2b(a)) }
}

public func <<< <A, B, C>(
  _ b2c: @escaping (B) async -> C,
  _ a2b: @escaping (A) async -> B
) -> (A) async -> C {
  return { a in await b2c(a2b(a)) }
}
