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
        
        let dependencies = try NSRegularExpression(
            pattern: "(Package\\(\\n?(\\s*)name\\s*:\\s*\".*?\"\\s*,?\\s*(providers\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?(products\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?(\\n?(\\s*)dependencies\\s*:\\s*\\[)(\\n?\\s*))(\\]|(.|\\n)*?\\),?\\s*\\])",
            options: []
        )
        let array = try NSRegularExpression(
            pattern: "Package\\(\\n?(\\s*)name\\s*:\\s*\".*?\"\\s*,?\\s*(providers\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?(products\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?dependencies",
            options: []
        )
        let before = try NSRegularExpression(
            pattern: "(Package\\(\\n?(\\s*)name\\s*:\\s*\".*?\"\\s*,?\\s*(providers\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?(products\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)))?)(,)?",
            options: []
        )
        let stored = try NSRegularExpression(pattern: "\\.package\\(url\\s*:\\s*\"\(self.url)\".*?\\)(?=\\s*,|\\s*\\])", options: [])
        
        if array.matches(in: String(contents), options: [], range: contents.range).count > 0 {
            if stored.matches(in: String(contents), options: [], range: contents.range).count > 0 {
                stored.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: self.description)
            } else {
                let match = dependencies.firstMatch(in: String(contents), options: [], range: contents.range)
                let space = contents.substring(with: match?.range(at: 9) ?? NSMakeRange(0, 0))
                
                if space == "" {
                    dependencies.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "$1\n$2$2\(self.description)\n$2]")
                } else {
                    dependencies.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "$1\(self.description),$9$10")
                }
            }
        } else {
            before.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: """
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
