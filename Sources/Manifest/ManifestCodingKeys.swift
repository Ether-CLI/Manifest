extension Manifest {
    
    /// Keys for encoding a `Manifest` instance.
    public typealias CodingKeys = ManifestCodingKeys
}

/// Keys for encoding a `Manifest` instance.
public enum ManifestCodingKeys: String, CodingKey {
    
    ///
    case name
    
    ///
    case pkgConfig
    
    ///
    case providers
    
    ///
    case products
    
    ///
    case dependencies
    
    ///
    case targets
}
