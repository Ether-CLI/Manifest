import Foundation
import Utilities

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
    
    /// Get an element in `Package.dependencies` array from the project's manifest.
    ///
    /// - Parameter url: The URL of the dependency to fetch.
    ///
    /// - Returns: `Package.dependencies`
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    public func dependency(withURL url: String)throws -> Dependency? {
        let pattern = try NSRegularExpression(pattern: "\\.package\\(\\s*url\\s*:\\s*\"\(url)\"\\s*,\\s*(.*?)\\)(?=\\s*,|\\s*\\])", options: [])
        let contents: String = try self.contents()
        
        return try pattern.matches(in: contents, options: [], range: contents.range).map { (match) in
            guard let url = contents.substring(at: match.range(at: 1)) else {
                throw ManifestError.noStringAtRange(match.range(at: 1))
            }
            guard let version = contents.substring(at: match.range(at: 2)) else {
                throw ManifestError.noStringAtRange(match.range(at: 2))
            }
            
            return try Dependency(manifest: self, url: url, version: version)
        }.first
    }
}
