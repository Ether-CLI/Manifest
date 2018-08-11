/// The full structure of a `Package.resolved` file.
public struct Resolved: Codable {
    
    /// The value for the `.resolved` JSON's `object` key.
    public let object: Pins
    
    /// Not sure what this is for, but it exists.
    public let version: Int
}

/// Holds the array of dependency pins.
public struct Pins: Codable {
    
    /// The pins for the projects dependecnies.
    public let pins: [Pin]
}

/// A pin for a dependedny.
public struct Pin: Codable {
    
    /// The name of the package.
    public let package: String
    
    /// The `.git` URL of the dependency.
    public let repositoryURL: String
    
    /// The version data of the dependecy pulled into the dependeny.
    public let state: PinState
}

/// The version data for a dependeny pin.
public struct PinState: Codable {
    
    /// The branch of the depenency that is being used.
    public let branch: String?
    
    /// The current git revision of the dependency that was fetched.
    public let revision: String
    
    /// The current git tag of the dependency that is pulled into the project.
    public let version: String?
}
