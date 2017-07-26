import Vapor
import HTTP

final class DashboardController {

    let view: ViewRenderer

    init(_ view: ViewRenderer) {
        self.view = view
    }

    /// GET /admin/login
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try req.makeView("invigilator/admin/dashboard", "dashboard")
    }
}