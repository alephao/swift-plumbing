import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

enum AssetCodegenError: Error {
  case failedToEnumerate(String)
}

private let defaultIgnoreFiles: Set<String> = [".DS_Store", ".gitkeep"]

struct AssetPath {
  let url: URL
  let dir: String

  init(url: URL, rootURL: URL) {
    self.url = url
    self.dir = url
      .absoluteString
      .replacingOccurrences(of: rootURL.absoluteString, with: "")
      .replacingOccurrences(of: url.lastPathComponent, with: "")
  }
}

public func assetsCodegen(
  publicAssetsRootPath: String,
  checksum: Bool
) throws -> String {
  let enumName = "PublicAsset"
  let dictName = "publicAssetsMapping"
  let emptyFile = """
    extension \(enumName) { }

    public let \(dictName): [String: String] = [:]

    """

  let fileManager = FileManager.default

  let files = try fileManager.ls(
    publicAssetsRootPath,
    ignoring: { defaultIgnoreFiles.contains($0) },
    recursive: true
  )

  if files.count == 0 {
    return emptyFile
  }

  let staticReferences = staticReferencesDeclr(
    basePath: publicAssetsRootPath,
    pathComponents: [],
    files: files,
    checksum: checksum
  )

  if staticReferences == "" {
    return emptyFile
  }

  let pathReferences =
    ("extension \(enumName) {") + "\n"
    + staticReferences + "\n"
    + "}"

  let dictValues = dictDeclr(
    rootEnumName: enumName,
    basePath: publicAssetsRootPath,
    pathComponents: [],
    files: files,
    checksum: checksum
  )

  let dict =
    ("public let \(dictName): [String: String] = [") + "\n"
    + dictValues + "\n"
    + "]"

  return pathReferences + "\n\n" + dict
}

func staticReferencesDeclr(
  basePath: String,
  pathComponents: [String],
  files: [FileOrDir],
  checksum: Bool
) -> String {
  files.compactMap({ f -> String? in
    switch f {
    case .file(let fileName):
      let variableName = kebabToSnakeCase(specialCharsToUnderscore(fileName))

      var declrValue: String
      if checksum {
        #if os(Linux)
          let hash = bytes4(
            try! Data(
              contentsOf: URL(
                fileURLWithPath: ([basePath] + pathComponents + [fileName]).joined(separator: "/")
              )
            )
          )
        #else
          let hash = bytes4(
            try! Data(
              contentsOf: URL(
                filePath: ([basePath] + pathComponents + [fileName]).joined(separator: "/")
              )
            )
          )
        #endif
        var fileNameComponents = fileName.split(separator: ".")
        let ext = fileNameComponents.removeLast()
        let fileNameWithHash = fileNameComponents.joined(separator: ".") + "." + hash + "." + ext
        declrValue = "/" + (pathComponents + [fileNameWithHash]).joined(separator: "/")
      } else {
        declrValue = "/" + (pathComponents + [fileName]).joined(separator: "/")
      }

      let varName =
        (variableName.first?.isNumber ?? false)
        ? "_\(variableName)"
        : variableName
      let declr = "public static let \(varName): String = \"\(declrValue)\""
      return indentLine(pathComponents.count + 1)(declr)
    case .dir(let dirName, let subpaths):
      if subpaths.count == 0 { return nil }

      let enumName = kebabToSnakeCase(dirName)
      let values = staticReferencesDeclr(
        basePath: basePath,
        pathComponents: pathComponents + [dirName],
        files: subpaths,
        checksum: checksum
      )
      return indentLine(pathComponents.count + 1)("public enum \(enumName) {") + "\n"
        + values + "\n"
        + indentLine(pathComponents.count + 1)("}")
    }
  })
  .joined(separator: "\n")
}

func dictDeclr(
  rootEnumName: String,
  basePath: String,
  pathComponents: [String],
  files: [FileOrDir],
  checksum: Bool
) -> String {
  files.compactMap({ f -> String? in
    switch f {
    case .file(let fileName):
      let variableName = kebabToSnakeCase(specialCharsToUnderscore(fileName))
      let varName =
        (variableName.first?.isNumber ?? false)
        ? "_\(variableName)"
        : variableName
      let key = ([rootEnumName] + (pathComponents.map(kebabToSnakeCase)) + [varName])
        .joined(separator: ".")

      let value: String
      if checksum {
        value = "\"/" + (pathComponents + [fileName]).joined(separator: "/") + "\""
      } else {
        value = key
      }

      return indentLine(1)("\(key): \(value),")
    case .dir(let dirName, let subpaths):
      if subpaths.count == 0 { return nil }
      return dictDeclr(
        rootEnumName: rootEnumName,
        basePath: basePath,
        pathComponents: pathComponents + [dirName],
        files: subpaths,
        checksum: checksum
      )
    }
  })
  .joined(separator: "\n")
}

func indentLine(_ level: Int = 1) -> (String) -> String {
  { line in String(repeating: "  ", count: level < 0 ? 0 : level) + line }
}

func kebabToCamelCase(_ text: String) -> String {
  let components = text.split(separator: "-")
  return components[0].lowercased()
    + components[1..<components.endIndex].map(\.capitalized).joined()
}

func kebabToSnakeCase(_ text: String) -> String {
  text.replacingOccurrences(of: "-", with: "_")
}

func specialCharsToUnderscore(_ text: String) -> String {
  dotsToUnderscore(atToUnderscore(text))
}

func dotsToUnderscore(_ text: String) -> String {
  text.replacingOccurrences(of: ".", with: "_")
}

func atToUnderscore(_ text: String) -> String {
  text.replacingOccurrences(of: "@", with: "_")
}
