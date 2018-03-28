import Foundation
import Utilities

/// An external package that the current project relies on.
/// These are stored in the manifest's `dependencies` array.
public final class Dependency: CustomStringConvertible {
    
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

extension Manifest {
    
    /// Get all the elements in `Package.dependencies` array from the project's manifest.
    ///
    /// - Returns: `Package.dependencies`
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    public func dependencies()throws -> [Dependency] {
        let pattern = try NSRegularExpression(pattern: "\\.package\\(\\s*url\\s*:\\s*\"(.*?)\"\\s*,\\s*(.*?)\\)(?=\\s*,|\\s*\\])", options: [])
        let contents: String = try self.contents()
        
        return try pattern.matches(in: contents, options: [], range: contents.range).map { (match) in
            guard let url = contents.substring(at: match.range(at: 1)) else {
                throw ManifestError.noStringAtRange(match.range(at: 1))
            }
            guard let version = contents.substring(at: match.range(at: 2)) else {
                throw ManifestError.noStringAtRange(match.range(at: 2))
            }
            
            return try Dependency(manifest: self, url: url, version: version)
        }
    }
}
