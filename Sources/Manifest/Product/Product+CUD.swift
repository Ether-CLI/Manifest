import Foundation
import Utilities

extension Product: Saveable {
    
    /// Updates the product's instance in the project's manifest.
    /// If the product does not exist in the manifest
    public func save() throws {
        let pattern: NSRegularExpression
        let replacement: String
        let contents: NSMutableString = try self.manifest.contents()
        
        if let name = self.fetchedName {
            pattern = try NSRegularExpression(pattern: "\\.\(self.type.rawValue)\\(name\\s*:\\s*\"\(name)\".*?\\)", options: [])
            replacement = self.description
        } else {
            let productsArray = try NSRegularExpression(
                pattern: "Package\\(\\s*name\\s*:\\s*\".*?\"\\s*,\\s*(?:providers\\s*:\\s*\\[(?:.|\\n)*?\\]\\s*(?!\\)),)?\\n?(\\s*)products\\s*:\\s*\\[",
                options: []
            )
            
            if productsArray.matches(in: String(contents), options: [], range: contents.range).count > 0 {
                pattern = productsArray
                replacement = "$0\n$1$1\(self.description),\n"
            } else {
                pattern = try NSRegularExpression(
                    pattern: "(Package\\(\\n?(\\s*)name\\s*:\\s*\".*?\"\\s*,\\s*(?:providers\\s*:\\s*\\[(?:.|\\n)*?\\]\\s*(?!\\)))?)(,)?",
                    options: []
                )
                replacement = """
                $1,
                $2products: [
                $2$2\(self.description)
                $2]$3
                """
            }
        }
        
        pattern.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: replacement)
        try self.manifest.write(with: contents)
    }
}

extension Product: Deletable {
    
    /// Removes the product instance
    /// from the manifest's `Package.products` array.
    ///
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    public func delete() throws {
        let pattern = try NSRegularExpression(
            pattern: "\\.(?:executable|library)\\(name\\s*:\\s*\"\(self.name)\"\\s*(?:,\\s*type\\s*:\\s*\\.(static|dynamic)\\s*)?(?:,\\s*targets\\s*:\\s*(\\[.*?\\]))?\\),?",
            options: []
        )
        let contents: NSMutableString = try self.manifest.contents()
        
        pattern.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "")
        try self.manifest.write(with: contents)
    }
}
