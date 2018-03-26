import Foundation
import Utilities

/// A product that is vended by the parent package.
///
/// For more information, visit the [SPM docs](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#products).
public final class Product: CustomStringConvertible {
    
    /// Denotes wheather the product is a library or an executable.
    public let type: ProductType
    
    /// The name of the target.
    public var name: String
    
    /// How the product gets linked to a client project if it is a library.
    public var linking: LibraryLinkingType?
    
    /// The package's targets that the product can access.
    public var targets: [String]
    
    /// The name of the `Product` object
    /// when it is fetched from the manifest.
    internal var fetchedName: String?
    
    private let manifest: Manifest
    
    ///
    public init(type: ProductType, name: String, linking: LibraryLinkingType?, targets: [String]) {
        self.type = type
        self.name = name
        self.linking = linking
        self.targets = targets
        self.manifest = Manifest.current
    }
    
    /// Used to create `Product` objects that who's data is fecthed from the project manifest.
    internal init(from manifest: Manifest, withType type: ProductType, name: String, linking: LibraryLinkingType?, targets: [String]) {
        self.type = type
        self.name = name
        self.linking = linking
        self.targets = targets
        
        self.fetchedName = name
        self.manifest = manifest
    }
    
    /// The product formatted for the manifest.
    public var description: String {
        return "." + type.rawValue + "(" +
            "name: \"\(self.name)\", " +
            ((type == .library && linking != nil) ? "type: .\(self.linking!.rawValue), " : "") +
            "targets: \(self.targets.description)" +
        ")"
    }
}

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
