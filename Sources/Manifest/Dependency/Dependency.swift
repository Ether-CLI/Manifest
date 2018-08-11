import Foundation
import Utilities

/// An external package that the current project relies on.
/// These are stored in the manifest's `dependencies` array.
public final class Dependency: ManifestElement, CustomStringConvertible, Codable {
    
    /// Keys used to encode/decode a `Target` object.
    public typealias CodingKeys = DependencyCodingKeys
    
    /// The URI or path to the dependency.
    public let url: String
    
    /// The version of the dependency.
    /// This could be one of multiple cases
    public var version: DependencyVersionType
    
    ///
    public var manifest: Manifest
    
    ///
    public init(url: String, version: DependencyVersionType) {
        self.url = url
        self.version = version
        self.manifest = Manifest.current
    }
    
    ///
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DependencyCodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        self.version = try DependencyVersionType(from: container.decode(String.self, forKey: .version))
        self.manifest = Manifest.current
    }
    
    ///
    internal init(manifest: Manifest, url: String, version: String)throws {
        self.url = url
        self.version = try DependencyVersionType(from: version)
        self.manifest = manifest
    }
    
    /// The dependency formatted for the manifest.
    public var description: String {
        return ".package(url: \"\(self.url)\", \(self.version.description))"
    }
    
    ///
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DependencyCodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(version.description, forKey: .version)
    }
}

/// Keys used to encode/decode a `Target` object.
public enum DependencyCodingKeys: CodingKey {
    
    ///
    case url
    
    ///
    case version
}
