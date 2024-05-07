public func |> <A, B> (_ a: A, f: (A) -> B) -> B {
  f(a)
}

public func |> <A, B> (_ a: A, f: (A) async -> B) async -> B {
  await f(a)
}
