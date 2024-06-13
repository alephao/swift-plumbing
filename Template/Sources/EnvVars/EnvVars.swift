import Dependencies
import Foundation

public struct EnvVars: Codable {
  public var appEnv: AppEnv
  public var appSecret: String
  public var baseUrl: URL
  public var databaseUrl: String
  public var host: String
  public var port: Int

  public init(
    appEnv: AppEnv = .dev,
    appSecret: String = "deadbeefdeadbeefdeadbeefdeadbeef",
    baseUrl: URL = URL(string: "http://localhost:8080")!,
    databaseUrl: String = "sql/sqlite.db",
    host: String = "0.0.0.0",
    port: Int = 8080
  ) {
    self.appEnv = appEnv
    self.appSecret = appSecret
    self.baseUrl = baseUrl
    self.databaseUrl = databaseUrl
    self.host = host
    self.port = port
  }

  public enum CodingKeys: String, CodingKey {
    case appEnv = "APP_ENV"
    case appSecret = "APP_SECRET"
    case baseUrl = "BASE_URL"
    case databaseUrl = "DATABASE_URL"
    case host = "HOST"
    case port = "PORT"
  }
}

extension EnvVars {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    appEnv = try container.decode(AppEnv.self, forKey: .appEnv)
    appSecret = try container.decode(String.self, forKey: .appSecret)
    baseUrl = try container.decode(URL.self, forKey: .baseUrl)
    databaseUrl = try container.decode(String.self, forKey: .databaseUrl)
    host = try container.decode(String.self, forKey: .host)
    port = Int(try container.decode(String.self, forKey: .port))!
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.appEnv, forKey: .appEnv)
    try container.encode(self.appSecret, forKey: .appSecret)
    try container.encode(self.baseUrl, forKey: .baseUrl)
    try container.encode(self.databaseUrl, forKey: .databaseUrl)
    try container.encode(self.host, forKey: .host)
    try container.encode(String(self.port), forKey: .port)
  }
}
