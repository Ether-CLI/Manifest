/// The full structure of a `Package.resolved` file.
struct Resolved: Codable {
    
    /// The value for the `.resolved` JSON's `object` key.
    let object: Pins
    
    /// Not sure what this is for, but it exists.
    let version: Int
}

/// Holds the array of dependency pins.
struct Pins: Codable {
    
    /// The pins for the projects dependecnies.
    let pins: [Pin]
}

/// A pin for a dependedny.
struct Pin: Codable {
    
    /// The name of the package.
    let package: String
    
    /// The `.git` URL of the dependency.
    let repositoryURL: String
    
    /// The version data of the dependecy pulled into the dependeny.
    let state: PinState
}

/// The version data for a dependeny pin.
struct PinState: Codable {
    
    /// The branch of the depenency that is being used.
    let branch: String?
    
    /// The current git revision of the dependency that was fetched.
    let revision: String
    
    /// The current git tag of the dependency that is pulled into the project.
    let version: String?
}
