
/// A type that can be written to a manifest as a value to initialize a `Package` instance.
public protocol ManifestElement: class {
    
    /// The parent manifest of the element.
    var manifest: Manifest { get set }
}
