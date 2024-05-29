import Tuple

public func prepend<A, B>(_ a: A, _ b: B) -> T2<B, A> { b .*. a }
public func discardLeft<A, B>(_ t: Tuple<A, B>) -> B { t.second }
public func discardRight<A, B>(_ t: Tuple<A, B>) -> A { t.first }

public func applyTuple<A, Z, Value>(
  _ f: @escaping (A, Z) -> Value
) -> (T2<A, Z>) -> Value {
  { t in f(get1(t), rest(t)) }
}

public func applyTuple<A, B, Z, Value>(
  _ f: @escaping (A, B, Z) -> Value
) -> (T3<A, B, Z>) -> Value {
  { t in f(get1(t), get2(t), rest(t)) }
}

public func applyTuple<A, B, C, Z, Value>(
  _ f: @escaping (A, B, C, Z) -> Value
) -> (T4<A, B, C, Z>) -> Value {
  { t in f(get1(t), get2(t), get3(t), rest(t)) }
}
