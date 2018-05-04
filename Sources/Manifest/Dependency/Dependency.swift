import Foundation
import Utilities

/// An external package that the current project relies on.
/// These are stored in the manifest's `dependencies` array.
public final class Dependency: CustomStringConvertible {
    
    /// Keys used to encode/decode a `Target` object.
    public typealias CodingKeys = DependencyCodingKeys
    
    /// The URI or path to the dependency.
    public let url: String
    
    /// The version of the dependency.
    /// This could be one of multiple cases
    public var version: DependencyVersionType
    
    ///
    internal let manifest: Manifest
    
    ///
    public init(url: String, version: DependencyVersionType) {
        self.url = url
        self.version = version
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
}

/// Keys used to encode/decode a `Target` object.
public enum DependencyCodingKeys: CodingKey {
    
    ///
    case url
    
    ///
    case version
}
