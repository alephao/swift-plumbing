public typealias T2<A, Z> = (A, Z)
public typealias T3<A, B, Z> = (A, (B, Z))
public typealias T4<A, B, C, Z> = (A, (B, (C, Z)))
public typealias T5<A, B, C, D, Z> = (A, (B, (C, (D, Z))))
public typealias T6<A, B, C, D, E, Z> = (A, (B, (C, (D, (E, Z)))))
public typealias T7<A, B, C, D, E, F, Z> = (A, (B, (C, (D, (E, (F, Z))))))
public typealias T8<A, B, C, D, E, F, G, Z> = (A, (B, (C, (D, (E, (F, (G, Z)))))))

precedencegroup TupleAppend {
  associativity: right
}
infix operator .*.: TupleAppend

public func .*. <A, B> (lhs: A, rhs: B) -> T2<A, B> {
  (lhs, rhs)
}

public func prepend<A, B>(_ a: A, _ b: B) -> T2<B, A> { b .*. a }

public func get1<A, Z>(_ t: T2<A, Z>) -> A { t.0 }
public func get2<A, B, Z>(_ t: T3<A, B, Z>) -> B { t.1.0 }
public func get3<A, B, C, Z>(_ t: T4<A, B, C, Z>) -> C { t.1.1.0 }
public func get4<A, B, C, D, Z>(_ t: T5<A, B, C, D, Z>) -> D { t.1.1.1.0 }
public func get5<A, B, C, D, E, Z>(_ t: T6<A, B, C, D, E, Z>) -> E { t.1.1.1.1.0 }
public func get6<A, B, C, D, E, F, Z>(_ t: T7<A, B, C, D, E, F, Z>) -> F { t.1.1.1.1.1.0 }
public func get7<A, B, C, D, E, F, G, Z>(_ t: T8<A, B, C, D, E, F, G, Z>) -> G { t.1.1.1.1.1.1.0 }

public func rest<A, Z>(_ t: T2<A, Z>) -> Z { t.1 }
public func rest<A, B, Z>(_ t: T3<A, B, Z>) -> Z { t.1.1 }
public func rest<A, B, C, Z>(_ t: T4<A, B, C, Z>) -> Z { t.1.1.1 }
public func rest<A, B, C, D, Z>(_ t: T5<A, B, C, D, Z>) -> Z { t.1.1.1.1 }
public func rest<A, B, C, D, E, Z>(_ t: T6<A, B, C, D, E, Z>) -> Z { t.1.1.1.1.1 }
public func rest<A, B, C, D, E, F, Z>(_ t: T7<A, B, C, D, E, F, Z>) -> Z { t.1.1.1.1.1.1 }
public func rest<A, B, C, D, E, F, G, Z>(_ t: T8<A, B, C, D, E, F, G, Z>) -> Z { t.1.1.1.1.1.1.1 }

public func over1<A, R, Z>(_ f: @escaping (A) -> R) -> (T2<A, Z>) -> T2<R, Z> {
  { t in f(get1(t)) .*. rest(t) }
}

public func over2<A, B, R, Z>(_ f: @escaping (B) -> R) -> (T3<A, B, Z>) -> T3<A, R, Z> {
  { t in get1(t) .*. f(get2(t)) .*. rest(t) }
}

public func over3<A, B, C, R, Z>(_ f: @escaping (C) -> R) -> (T4<A, B, C, Z>) -> T4<A, B, R, Z> {
  { t in get1(t) .*. get2(t) .*. f(get3(t)) .*. rest(t) }
}

public func over4<A, B, C, D, R, Z>(_ f: @escaping (D) -> R) -> (T5<A, B, C, D, Z>) -> T5<A, B, C, R, Z> {
  { t in get1(t) .*. get2(t) .*. get3(t) .*. f(get4(t)) .*. rest(t) }
}

public func over5<A, B, C, D, E, R, Z>(_ f: @escaping (E) -> R) -> (T6<A, B, C, D, E, Z>) -> T6<A, B, C, D, R, Z> {
  { t in get1(t) .*. get2(t) .*. get3(t) .*. get4(t) .*. f(get5(t)) .*. rest(t) }
}

public func over6<A, B, C, D, E, F, R, Z>(_ f: @escaping (F) -> R) -> (T7<A, B, C, D, E, F, Z>) -> T7<A, B, C, D, E, R, Z> {
  { t in get1(t) .*. get2(t) .*. get3(t) .*. get4(t) .*. get5(t) .*. f(get6(t)) .*. rest(t) }
}
