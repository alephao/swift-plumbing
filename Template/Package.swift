// swift-tools-version:5.10
import PackageDescription

let package = Package(
  name: "swift-plumbing-template",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .executable(name: "Server", targets: ["Server"]),
    .library(name: "Application", targets: ["Application"]),
    .plumb(.router),
    .plumb(.publicAssets),
    .plumb(.deps),
    .plumb(.envVars),
  ],
  dependencies: [
    //    .package(name: "swift-plumbing", path: "../"),
    .package(url: "https://github.com/alephao/swift-plumbing.git", exact: "0.29.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.0.0"),
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "Server",
      dependencies: [
        "Application",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .target(
      name: "Application",
      dependencies: [
        .plumb(.router),
        .plumb(.publicAssets),
        .plumb(.deps),
        .product(name: "Plumbing", package: "swift-plumbing"),
        .product(name: "PlumbingHummingbird", package: "swift-plumbing"),
        .product(name: "PublicAssetsMiddleware", package: "swift-plumbing"),
        .product(name: "LoggerMiddleware", package: "swift-plumbing"),
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "Logging", package: "swift-log"),
      ]
    ),
    .plumb(.deps),
    .plumb(.publicAssets),
    .plumb(.router),
    .plumb(.envVars),
  ]
)

struct PlumbTarget {
  let target: Target

  init(_ target: Target) {
    self.target = target
  }

  var asDependency: Target.Dependency {
    .byName(name: target.name)
  }
}

extension Target {
  static func plumb(_ target: PlumbTarget) -> Target {
    return target.target
  }
}

extension Target.Dependency {
  static func plumb(_ target: PlumbTarget) -> Target.Dependency {
    return .byName(name: target.target.name)
  }
}

extension Product {
  static func plumb(_ target: PlumbTarget) -> Product {
    return .library(name: target.target.name, targets: [target.target.name])
  }
}

extension PlumbTarget {
  static let router: PlumbTarget = PlumbTarget(
    .target(
      name: "Router",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "URLRouting", package: "swift-url-routing"),
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "PlumbingHummingbird", package: "swift-plumbing"),
        .product(name: "Logging", package: "swift-log"),
      ]
    )
  )

  static let publicAssets: PlumbTarget = PlumbTarget(
    .target(
      name: "PublicAssets",
      plugins: [
        .plugin(name: "AssetsCodegenPlugin", package: "swift-plumbing")
      ]
    )
  )

  static let deps: PlumbTarget = PlumbTarget(
    .target(
      name: "Deps",
      dependencies: [
        .plumb(.router),
        .plumb(.envVars),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Logging", package: "swift-log"),
      ]
    )
  )

  static let envVars: PlumbTarget = PlumbTarget(
    .target(
      name: "EnvVars",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    )
  )
}
