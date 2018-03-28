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

extension Dependency: Saveable {
    
    /// Updates the dependency's instance in the project's manifest.
    /// If the instance does not exist yet, it will be created.
    ///
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    public func save() throws {
        let contents: NSMutableString = try self.manifest.contents()
        
        if try NSRegularExpression(
            pattern: "Package\\(\\n?(\\s*)name\\s*:\\s*\".*?\"\\s*,?\\s*(providers\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?(products\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?dependencies",
            options: []
        ).matches(in: String(contents), options: [], range: contents.range).count > 0 {
            let stored = try NSRegularExpression(pattern: "\\.package\\(url\\s*:\\s*\"\(self.url)\".*?\\)(?=\\s*,|\\s*\\])", options: [])
            if stored.matches(in: String(contents), options: [], range: contents.range).count > 0 {
                stored.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: self.description)
            } else {
                let pattern = try NSRegularExpression(pattern: "(\\n?(\\s*)dependencies\\s*:\\s*\\[)(\\n?\\s*)(\\]|(.|\\n)*?\\)\\s*\\])", options: [])
                pattern.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: """
                $1
                $2$2\(self.description),
                $3$4
                """)
            }
        } else {
            let pattern = try NSRegularExpression(
                pattern: "(Package\\(\\n?(\\s*)name\\s*:\\s*\".*?\"\\s*,?\\s*(providers\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?(products\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)))?)(,)?",
                options: []
            )
            pattern.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: """
            $1,
            $2dependenciesw: [
            $2$2\(self.description)
            $2]$7
            """)
        }
        
        try self.manifest.write(with: contents)
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
