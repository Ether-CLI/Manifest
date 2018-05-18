import Foundation
import Utilities

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
                let pattern = try NSRegularExpression(pattern: "(Package\\(\\n?(\\s*)name\\s*:\\s*\".*?\"\\s*,?\\s*(providers\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?(products\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?(\\n?(\\s*)dependencies\\s*:\\s*\\[)(\\n?\\s*))(\\]|(.|\\n)*?\\)\\s*\\])", options: [])
                pattern.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "$1\(self.description),$9$10")
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

extension Dependency: Deletable {
    
    /// Removes the dependency instance
    /// from the manifest's `Package.dependencies` array.
    ///
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    public func delete() throws {
        let pattern = try NSRegularExpression(pattern: "\\h*\\.package\\(\\s*url\\s*:\\s*\"\(self.url)\".*?\\),?(?=\\s*\\]|\\s*\\n|\\s*\\.)\n?", options: [])
        let contents: NSMutableString = try self.manifest.contents()
        
        pattern.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "")
        try self.manifest.write(with: contents)
    }
}
