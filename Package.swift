// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "swift-plumbing",
  platforms: [
    .macOS(.v14),
    .iOS(.v15),
  ],
  products: [
    .executable(name: "plumb", targets: ["Plumb"]),
    .library(name: "Plumbing", targets: ["Plumbing"]),
    .library(name: "PlumbingHttp", targets: ["PlumbingHttp"]),
    .library(name: "PlumbingHttpRouter", targets: ["PlumbingHttpRouter"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0-beta.4"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.0"),
  ],
  targets: [
    .executableTarget(
      name: "Plumb",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .target(name: "Plumbing"),
    .target(
      name: "PlumbingHttp",
      dependencies: [
        .product(name: "Hummingbird", package: "hummingbird")
      ]
    ),
    .target(
      name: "PlumbingHttpRouter",
      dependencies: [
        "PlumbingHttp",
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "URLRouting", package: "swift-url-routing"),
      ]
    ),
  ]
)
