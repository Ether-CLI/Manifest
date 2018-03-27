/// An external package that the current project relies on.
/// These are stored in the manifest's `dependencies` array.
public final class Dependency {
    
    /// The URI or path to the dependency.
    public let url: String
    
    /// The version of the dependency.
    /// This could be one of multiple cases
    public var version: DependencyVersionType
    
    ///
    internal let manifest: Manifest
    
    ///
    public init(url: String, version: DependencyVersionType) {
        self.url = url
        self.version = version
        self.manifest = Manifest.current
    }
    
    ///
    internal init(manifest: Manifest, url: String, version: String)throws {
        self.url = url
        self.version = try DependencyVersionType(from: version)
        self.manifest = manifest
    }
}