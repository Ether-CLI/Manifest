import Foundation
import Utilities

extension Manifest {
    
    /// Get all the elements in `Package.providers` from the project's manifest.
    ///
    /// - Returns: `Package.providers`
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    func providers()throws -> [Provider] {
        let brew = try NSRegularExpression(pattern: "\\.brew\\((\\[.*?\\])\\)", options: [])
        let apt = try NSRegularExpression(pattern: "\\.apt\\((\\[.*?\\])\\)", options: [])
        let contents: String = try self.contents()
        
        let brewProviders: [Provider] = brew.matches(in: contents, options: [], range: contents.range).map { (match) in
            let packages = contents.parseArray(at: match.range(at: 1))
            return Provider(type: .brew, packages: packages, manifest: self)
        }
        let aptProviders: [Provider] = apt.matches(in: contents, options: [], range: contents.range).map { (match) in
            let packages = contents.parseArray(at: match.range(at: 1))
            return Provider(type: .apt, packages: packages, manifest: self)
        }
        
        return brewProviders + aptProviders
    }
}

/// Respresents a system package manager and the packages that should be installed through that given package manager.
///
/// More information [here](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#providers)
public struct Provider {
    
    /// The package manager that the provider represents
    public let type: ProviderType
    
    /// The packages to suggest installation for.
    public var packages: [String]
    
    /// The manifest instance used to mutate or fetch
    /// information from the project's manifest.
    private let manifest: Manifest
    
    ///
    internal init(type: ProviderType, packages: [String], manifest: Manifest? = nil) {
        self.type = type
        self.packages = packages
        self.manifest = manifest ?? Manifest.current
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
