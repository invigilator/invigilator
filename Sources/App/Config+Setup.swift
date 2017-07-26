import Vapor
import LeafProvider
import MySQLProvider
import AuthProvider
import Flash

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
        try setupMiddleware()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
    }

    private func setupPreparations() throws {
        preparations.append(User.self)
        preparations.append(CmsPage.self)
    }

    private func setupMiddleware() throws {
        addConfigurable(middleware: FlashMiddleware(), name: "flash")
        addConfigurable(middleware: ViewMiddleware.init, name: "view")

        let persistMiddleware = PersistMiddleware(User.self)
        addConfigurable(middleware: { (config) -> (PersistMiddleware<User>) in
            return persistMiddleware
        }, name: "invigilator-persist")
    }
}
