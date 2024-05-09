// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "swift-plumbing",
  platforms: [
    .macOS(.v14),
    .iOS(.v15),
  ],
  products: [
    .library(name: "Plumbing", targets: ["Plumbing"]),
    .library(name: "PlumbingHttp", targets: ["PlumbingHttp"]),
  ],
  dependencies: [
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0-beta.4")
  ],
  targets: [
    .target(name: "Plumbing"),
    .target(
      name: "PlumbingHttp",
      dependencies: [
        .product(name: "Hummingbird", package: "hummingbird")
      ]
    ),
  ]
)
