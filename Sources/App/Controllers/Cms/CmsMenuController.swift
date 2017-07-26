import Vapor
import HTTP

final class CmsMenuController {

    let view: ViewRenderer

    init(_ view: ViewRenderer) {
        self.view = view
    }

    /// GET /admin/login
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try req.makeView("invigilator/admin/cms/menu/index", "cmsMenus")
    }
}