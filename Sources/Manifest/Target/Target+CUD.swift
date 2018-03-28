import Foundation
import Utilities

extension Target: Saveable {
    
    /// Updates the target's instance in the projects manifest.
    /// If the instance does not exist yet, it will be created.
    ///
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    public func save() throws {
        let namePattern = "\\(name:\\s*\"\(self.name)\".*?\\)"
        let pattern = try NSRegularExpression(
            pattern: (self.isTest ? "\\.testTarget" : "\\.target") + namePattern,
            options: []
        )
        let contents: NSMutableString = try self.manifest.contents()
        
        if try NSRegularExpression(
            pattern: "(Package\\(\\n?(\\s*)name\\s*:\\s*\".*?\"\\s*,?\\s*(providers\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?(products\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?(dependencies\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)))?),?\\s*targets",
            options: []
            ).matches(in: String(contents), options: [], range: contents.range).count < 1 {
            try NSRegularExpression(
                pattern: "(Package\\(\\n?(\\s*)name\\s*:\\s*\".*?\"\\s*,?\\s*(providers\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?(products\\s*:\\s*\\[(.|\\n)*?\\](?!\\s*\\)),?\\s*)?(dependencies\\s*:\\s*\\[(.|\\n)*?\\])?)",
                options: []
                ).replaceMatches(
                    in: contents,
                    options: [],
                    range: contents.range,
                    withTemplate: """
                    $1,
                    $2targets: [
                    $2$2\(self.description)
                    $2]
                    """)
            try self.manifest.write(with: contents)
            return
        }
        
        if pattern.matches(in: String(contents), options: [], range: contents.range).count > 0 {
            pattern.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: self.description)
        } else if self.isTest {
            let replacement = try NSRegularExpression(pattern: "(?<=\\n|\\[)(\\s*)(\\.testTarget\\(.*?\\))(,?)(?=\\s*\\])", options: [])
            replacement.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "$1$2,\n$1\(self.description)")
        } else {
            let replacement = try NSRegularExpression(pattern: "(?<=\\n|\\[)(\\s*)(\\.target\\(.*?\\))(,?)(?=\\s*(\\.testTarget|\\]))", options: [])
            replacement.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "$1$2,\n$1\(self.description),")
        }
        
        try self.manifest.write(with: contents)
    }
}

extension Target: Deletable {
    
    /// Removes the target instance
    /// from the manifest's `Package.targets` array.
    ///
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    public func delete() throws {
        let type = self.isTest ? "testTarget" : "target"
        let pattern = try NSRegularExpression(pattern: "\\.\(type)\\(\\s*name\\s*:\\s*\"\(self.name)\".*?\\),?", options: [])
        let contents: NSMutableString = try self.manifest.contents()
        
        pattern.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "")
        try self.manifest.write(with: contents)
    }
}
