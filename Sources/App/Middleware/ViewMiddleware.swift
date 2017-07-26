import HTTP
import Vapor

final class ViewMiddleware: Middleware {
    let view: ViewRenderer
    init(_ view: ViewRenderer) {
        self.view = view
    }

    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        request.view = view
        return try next.respond(to: request)
    }
}

extension ViewMiddleware: ConfigInitializable {
    convenience init(config: Config) throws {
        let view = try config.resolveView()
        self.init(view)
    }
}

extension Request {
    var view: ViewRenderer? {
        get { return storage["cloud-dashboard:view"] as? ViewRenderer }
        set { storage["cloud-dashboard:view"] = newValue }
    }

    func assertView() throws -> ViewRenderer {
        guard let view = self.view else {
            throw Abort(.internalServerError, reason: "No view renderer set.")
        }

        return view
    }

    func makeView(
            _ path: String,
            _ active: String,
            _ node: Node
    ) throws -> View {
        var node = node
        try node.set("active", active)
        return try assertView().make(path, node, for: self)
    }

    func makeView(
            _ path: String,
            _ active: String,
            _ context: [String: NodeRepresentable?]? = nil
    ) throws -> View {
        let node = try context?.makeNode(in: nil) ?? Node([:])
        return try makeView(path, active, node)
    }
}