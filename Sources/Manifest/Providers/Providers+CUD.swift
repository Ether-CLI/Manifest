import Foundation
import Utilities

extension Provider: Saveable {
    
    /// Updates the provider's instance in the project's manifest.
    /// If the instance does not exist yet, it will be created.
    ///
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    public func save() throws {
        let providers = try NSRegularExpression(pattern: "\n?(\\s*)providers:\\s*\\[", options: [])
        let provider = try NSRegularExpression(pattern: "\\.\(self.type.rawValue)\\(\\[.*?\\]\\)", options: [])
        let contents: NSMutableString = try self.manifest.contents()
        
        if provider.matches(in: String(contents), options: [], range: contents.range).count > 0 {
            provider.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: self.description)
            try self.manifest.write(with: contents)
            return
        }
        
        if providers.matches(in: String(contents), options: [], range: contents.range).count > 0 {
            providers.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "$0\n$1$1\(self.description),")
        } else {
            let products = try NSRegularExpression(pattern: "\n?(\\s*)products: \\[", options: [])
            products.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: """
                
                $1providers: [
                $1    \(self.description)
                $1],$0
                """)
        }
        try self.manifest.write(with: contents)
    }
}

extension Provider: Deletable {
    
    /// Removes the provider instance
    /// from the manifest's `Package.providers` array.
    ///
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    public func delete() throws {
        let pattern = try NSRegularExpression(pattern: "\\.\(self.type.rawValue)\\(.*?\\),?", options: [])
        let contents: NSMutableString = try self.manifest.contents()
        
        pattern.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "")
        try self.manifest.write(with: contents)
    }
}
