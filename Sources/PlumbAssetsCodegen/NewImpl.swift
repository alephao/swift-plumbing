import Foundation

func _new_assetsCodegen(
  publicAssetsRootPath: String,
  checksum: Bool
) throws -> String {
  //  let rootURL = URL(filePath: publicAssetsRootPath)
  //  print(rootURL)
  //
  //  var errors: [(URL, String)] = []
  //  guard let inputFilesEnumerator = FileManager.default.enumerator(
  //    at: rootURL,
  //    includingPropertiesForKeys: [],
  //    options: [],
  //    errorHandler: { url, error in
  //      errors.append((url, error.localizedDescription))
  //      return false
  //    }
  //  ) else {
  //    throw AssetCodegenError.failedToEnumerate("Failed to enumerate path '\(rootURL.absoluteString)'")
  //  }
  //
  //  let inputFiles = inputFilesEnumerator
  //    .compactMap({ element -> AssetPath? in
  //      guard
  //        let url = element as? URL,
  //        !url.hasDirectoryPath,
  //        !defaultIgnoreFiles.contains(url.lastPathComponent)
  //      else { return nil }
  //      return AssetPath(url: url, rootURL: rootURL)
  //    })
  //
  //  // Enum Generation
  //  var enums = Set(inputFiles.map(\.dir))
  //  enums.remove("/")
  //
  //  let enumMapping = inputFiles.reduce(into: [String: [AssetPath]]()) { dict, asset in
  //    if dict[asset.dir] == nil {
  //      dict[asset.dir] = [asset]
  //    } else {
  //      dict[asset.dir]?.append(asset)
  //    }
  //  }
  //
  //  print(Set(inputFiles.map(\.dir)))
  return "noop"
}
