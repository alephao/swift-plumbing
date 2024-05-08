public func |> <A, B> (_ a: A, f: (A) -> B) -> B {
  f(a)
}

public func <| <A, B> (f: (A) -> B, a: A) -> B {
  f(a)
}

public func |> <A, B> (_ a: A, f: (A) async -> B) async -> B {
  await f(a)
}

public func <| <A, B> (f: (A) async -> B, a: A) async -> B {
  await f(a)
}
