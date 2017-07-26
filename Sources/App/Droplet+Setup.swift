@_exported import Vapor
import LeafProvider

extension Droplet {
    public func setup() throws {
        let routes = Routes(view)
        try collection(routes)

        try setupTags()
    }

    private func setupTags() throws {
        if let view = self.view as? LeafRenderer {
            view.stem.register(InviligatorMarkdown())
        }
    }
}
