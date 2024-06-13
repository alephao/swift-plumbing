import Application
import ArgumentParser

@main
struct Server: AsyncParsableCommand {
  func run() async throws {
    let app = buildApplication()
    try await app.runService()
  }
}
