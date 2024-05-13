import ArgumentParser

@main
struct Plumb: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "plumb",
    abstract: "🪠",
    version: "main",
    subcommands: [
      InitCommand.self,
      AssetsCommand.self,
      ImagesCommand.self,
    ]
  )
}
