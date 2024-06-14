import Application
import ArgumentParser

#if os(macOS) && DEBUG
  import Foundation
#endif

@main
struct Server: AsyncParsableCommand {
  func run() async throws {
    #if os(macOS) && DEBUG
      Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?
        .load()
    #endif

    let app = buildApplication()
    try await app.runService()
  }
}
