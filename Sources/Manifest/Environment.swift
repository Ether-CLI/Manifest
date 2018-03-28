/// Used for telling the current manifest instance what environment it is being used in.
public struct Environment: Equatable {
    
    /// The name of the environmnt
    public let name: String
    
    
    /// Used to tell the manifest instance that it is being used in the command-line.
    public static let commandline = Environment(name: "command-line")
    
    /// Used to tell the manifest it is being used to test it's methods on a string.
    public static let testing = Environment(name: "testing")
}
