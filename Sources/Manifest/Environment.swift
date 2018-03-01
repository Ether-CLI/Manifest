/// Used for telling the current manifest instance what environment it is being used in.
public struct Environment {
    
    /// The name of the environmnt
    let name: String
    
    
    /// Used to tell the manifest instance that it is being used in the command-line.
    static let commandline = Environment(name: "command-line")
    
    /// Used to tell the manifest it is being used to test it's methods on a string.
    static let testing = Environment(name: "testing")
}
