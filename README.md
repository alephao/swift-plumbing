# Plumbing

━━[W]┯━[I]━━[P]━╍╍╍━▶
     └╌╌━▶     
     
- short circuit
- deferred computation
- result 1st

## Deps

- Low-level networking handled by Hummingbird and SwiftNIO
- Dependency management with swift-dependencies
- Routing with swift-url-routing
- Html with swift-html
- Tests with swift-snapshot-testing

## Goals

- Composability
- Correctness
- Maintainability

## Operator APIs

There are 3 operator apis available, you shouldn't choose one way and use only that, they are more powerful when used together.

- Bind Functions: `<A, B, E: Error> (A) -> AsyncResult<B, E>`. Bind functions are the foundational unit for chaining operations, its signature is the transform function used in the flatMap/bind function.
- Method Chaining: `AsyncResult.<method>`. Most methods are just wrappers over Bind Functions, for example, `AsyncResult.parallel` is just `AsyncResult.flatMap(Bind.parallel(...))`. It allows you to chain a concrete AsyncResult like so `myAsyncResult.unwrap(...).parallel(...).fork(...)`
- Free Functions: `<A, B, E: Error> (AsyncResult<A, E>) -> AsyncResult<B, E>`. Free functions also uses Bind Functions under the hood, they are useful for function composition and as a middleware to AsyncResults.

You can compose all of them in single pipeline like the example below:

### Method Chaining


## Operators



# TODO

- [ ] Add option to instal InjectionIII - https://github.com/johnno1962/InjectionIII/releases/download/5.0.0/InjectionIII.app.zip
- [ ] Select Injection version to download depending on Xcode version?
- [ ] plumb init (Setup project) - empty dir or ask for package name
- [ ] plumb assets - share code for getting input files
- [ ] plumb assets - fix input files
- [ ] plumb sqlite3
- [ ] figure where is the best place to add AsyncResult extensions (MAYBE THE #if MACROS BELOW)
- [ ] AsyncResponse?
- [ ] Try #if macros for adding extra AsyncResult bindings, like in `Router` package, `#if canImport(Html)` add binginds.
- [ ] Configuration: Options(type safe config in pure swift; pickle; yaml/json)

- [X] plumb assets - use `[:]` when there are no files inside public
