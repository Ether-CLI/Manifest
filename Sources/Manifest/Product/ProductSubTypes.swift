/// Defines what type of a `Product` object
/// for the project's manifest.
public enum ProductType: String {
    
    ///
    case library
    
    ///
    case executable
}

/// Defines wheather a library should be linked to it's clients.
public enum LibraryLinkingType: String {
    
    ///
    case `static`
    
    ///
    case dynamic
}
