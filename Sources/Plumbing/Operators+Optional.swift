public func map<A, B>(_ transform: @escaping (A) -> B) -> (A?) -> B? {
  { a in a.map(transform) }
}

public func flatMap<A, B>(_ transform: @escaping (A) -> B?) -> (A?) -> B? {
  { a in a.flatMap(transform) }
}

public func >>= <A, B>(
  _ a: A?,
  _ transform: @escaping (A) -> B?
) -> B? {
  a.flatMap(transform)
}

public func >=> <A, B, C>(lhs: @escaping (A) -> B?, rhs: @escaping (B) -> C?) -> (A) -> C? {
  return lhs >>> flatMap(rhs)
}
