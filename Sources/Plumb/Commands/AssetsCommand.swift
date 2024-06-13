import ArgumentParser
import Foundation
import PlumbAssetsCodegen

// - Generate swift code referencing static assets
// - Map static assets with checksummed names to the original file name
struct AssetsCommand: ParsableCommand {
  static var configuration: CommandConfiguration = CommandConfiguration(commandName: "assets")

  @Option(help: "path to the public assets directory")
  public var path: String

  @Option(help: "path to generate the swift file")
  public var out: String

  @Flag()
  public var checksum: Bool = false

  init() {}

  func run() throws {
    let fileContents = try assetsCodegen(
      publicAssetsRootPath: path,
      checksum: checksum
    )

    if out == "stdout" {
      print(fileContents)
      return
    }

    let fm = FileManager()
    fm.createFile(atPath: out, contents: fileContents.data(using: .utf8))
  }
}
