import Foundation
import Utilities

extension Manifest {
    
    
    /// Gets the name of the `Package` declaration in the project's manifest.
    ///
    /// - Parameter name: A new name for the `Package` declaration.
    ///   If `nil` is passed in, the name remains the same.
    /// - Returns: The value passed into the manifest's `Package` initializer.
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    @discardableResult
    func name(equals name: String? = nil)throws -> String {
        let pattern = try NSRegularExpression(pattern: "(Package\\(\\s*name:\\s*\")(.*?)(\")", options: [])
        let content: NSMutableString = try self.contents()
        
        if let name = name {
            pattern.replaceMatches(in: content, options: [], range: content.range, withTemplate: "$1\(name)$3")
            try self.write(with: content)
            return name
        } else {
            guard let match = pattern.matches(in: String(content), options: [], range: content.range).first else {
                throw ManifestError(identifier: "missingManifestName", reason: "Attempted to access package name, but none where found")
            }
            return content.substring(with: match.range(at: 2))
        }
    }
    
    /// Gets the value of the `Package.pkgConfig` property.
    ///
    /// - Returns: `Package.pkgConfig`
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    func packageConfig()throws -> String? {
        let pattern = try NSRegularExpression(pattern: "\\n?\\s*pkgConfig:\\s*\"(.*?)\",?", options: [])
        let content: NSMutableString = try self.contents()
        
        guard let match = pattern.matches(in: String(content), options: [], range: content.range).first else {
            throw ManifestError(identifier: "missingManifestName", reason: "Attempted to access package name, but none where found")
        }
        return content.substring(with: match.range(at: 1))
    }
    
    /// Sets the value of the `Package.pkgConfig` property in the project's manifest.
    ///
    /// - Parameter string: The new value for `Package.pkgConfig`.
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    func packageConfig(equals string: String?)throws {
        let pattern = try NSRegularExpression(pattern: "(\\n?\\s*pkgConfig:\\s*\")(.*?)(\",?)", options: [])
        let content: NSMutableString = try self.contents()
        
        if let string = string {
            pattern.replaceMatches(in: content, options: [], range: content.range, withTemplate: "$1\(string)$3")
        } else {
            pattern.replaceMatches(in: content, options: [], range: content.range, withTemplate: "")
        }
        
        try self.write(with: content)
    }
}
