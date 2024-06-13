import Dependencies
import EnvVars
import Foundation

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

extension EnvVars: DependencyKey {
  public static var liveValue: Self {
    let envFilePath = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appendingPathComponent(".env.json")

    let defaultEnvVars = try! encoder.encode(EnvVars())
    let defaultEnvVarDict = try! decoder.decode([String: String].self, from: defaultEnvVars)

    let localEnvVarsData = try? Data(contentsOf: envFilePath)
    let localEnvVarDict =
      localEnvVarsData.flatMap { try? decoder.decode([String: String].self, from: $0) } ?? [:]

    let envVarDict =
      defaultEnvVarDict
      .merging(localEnvVarDict, uniquingKeysWith: { $1 })
      .merging(ProcessInfo.processInfo.environment, uniquingKeysWith: { $1 })

    let serialized = try! JSONSerialization.data(withJSONObject: envVarDict)
    return try! decoder.decode(EnvVars.self, from: serialized)
  }

  public static var testValue: EnvVars {
    var envVars = EnvVars()
    envVars.appEnv = .test
    envVars.databaseUrl = "sql/sqlite-test.db"
    return envVars
  }
}

extension EnvVars {
  public func assigningValuesFrom(_ env: [String: String]) -> EnvVars {
    let decoded =
      (try? encoder.encode(self))
      .flatMap { try? decoder.decode([String: String].self, from: $0) }
      ?? [:]

    let assigned = decoded.merging(env, uniquingKeysWith: { $1 })

    return (try? JSONSerialization.data(withJSONObject: assigned))
      .flatMap { try? decoder.decode(EnvVars.self, from: $0) }
      ?? self
  }
}
