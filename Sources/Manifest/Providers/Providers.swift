import Foundation
import Utilities

/// Respresents a system package manager and the packages that should be installed through that given package manager.
///
/// More information [here](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#providers)
public class Provider: CustomStringConvertible {
    
    /// The package manager that the provider represents
    public let type: ProviderType
    
    /// The packages to suggest installation for.
    public var packages: [String]
    
    /// The manifest instance used to mutate or fetch
    /// information from the project's manifest.
    internal let manifest: Manifest
    
    ///
    internal init(type: ProviderType, packages: [String], manifest: Manifest? = nil) {
        self.type = type
        self.packages = packages
        self.manifest = manifest ?? Manifest.current
    }
    
    /// The provider formatted for the manifest.
    public var description: String {
        return ".\(self.type.rawValue)(\(self.packages.description))"
    }
    
    /// Fetches the data from the `.brew`
    /// in the `Package.providers` array.
    ///
    /// - Parameter manifest: The manifest imstance to fetch the provider with.
    /// - Returns: A `Provider` instance with the data fetch from the project manifest.
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    static func brew(manifest: Manifest = Manifest.current)throws -> Provider {
        let pattern = try NSRegularExpression(pattern: "\\.brew\\((\\[.*?\\])\\)", options: [])
        let contents: NSMutableString = try manifest.contents()
        let matches = pattern.matches(in: String(contents), options: [], range: contents.range)
        
        guard let provider = matches.first else {
            throw ManifestError(identifier: "noBrewProvider", reason: "No `.brew` element found in the `Package.providers` array")
        }
        
        let packages = String(contents).parseArray(at: provider.range(at: 1))
        return Provider(type: .brew, packages: packages, manifest: manifest)
    }
    
    /// Fetches the data from the `.apt`
    /// in the `Package.providers` array.
    ///
    /// - Parameter manifest: The manifest imstance to fetch the provider with.
    /// - Returns: A `Provider` instance with the data fetch from the project manifest.
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    static func apt(manifest: Manifest = Manifest.current)throws -> Provider {
        let pattern = try NSRegularExpression(pattern: "\\.apt\\((\\[.*?\\])\\)", options: [])
        let contents: NSMutableString = try manifest.contents()
        let matches = pattern.matches(in: String(contents), options: [], range: contents.range)
        
        guard let provider = matches.first else {
            throw ManifestError(identifier: "noAPTProvider", reason: "No `.apt` element found in the `Package.providers` array")
        }
        
        let packages = String(contents).parseArray(at: provider.range(at: 1))
        return Provider(type: .apt, packages: packages, manifest: manifest)
    }
}

/// Designates which package manager the provider is for.
public enum ProviderType: String {
    
    ///
    case brew
    
    ///
    case apt
}
