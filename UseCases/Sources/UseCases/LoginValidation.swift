public struct LoginValidation {
    public init() {}
    
    public func callAsFunction(id: String, password: String) -> Bool {
        !(id.isEmpty || password.isEmpty)
    }
}
