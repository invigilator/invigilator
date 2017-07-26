import Vapor
import HTTP

final class CmsPageController {

    let view: ViewRenderer

    init(_ view: ViewRenderer) {
        self.view = view
    }

    /// GET /admin/login
    func index(_ req: Request) throws -> ResponseRepresentable {
        let pages = try CmsPage.makeQuery().sort("created", .descending).all()

        return try req.makeView("invigilator/admin/cms/page/index", "cmsPages", [
            "pages": pages
        ])
    }

    func view(_ req: Request) throws -> ResponseRepresentable {
        let slugUrl: String = try req.parameters.next()

        guard let cmsPage = try CmsPage.makeQuery().filter("slug_url", slugUrl).first() else {
            throw Abort.notFound
        }

        return try req.makeView("invigilator/cms/defaultPage.leaf", slugUrl, [
            "page": cmsPage
        ])
    }

    func create(_ req: Request) throws -> ResponseRepresentable {
        return try req.makeView("invigilator/admin/cms/page/edit", "cmsPages")
    }

    func store(_ req: Request) throws -> ResponseRepresentable {
        let page = try CmsPage(
                title: req.data["title"]?.string ?? "",
                contents: req.data["contents"]?.string ?? "",
                creationDate: Date(),
                slugUrl: req.data["slugUrl"]?.string ?? "",
                published: req.data["publish"]?.bool ?? false,
                metaTitle: req.data["metaTitle"]?.string ?? "",
                metaKeywords: req.data["metaKeywords"]?.string ?? "",
                metaDescription: req.data["metaDescription"]?.string ?? ""
        )
        try page.save()

        return Response(redirect: "/admin/cms/pages").flash(.success, "Page created")
    }

    func edit(_ req: Request) throws -> ResponseRepresentable {
        let page = try req.parameters.next(CmsPage.self)

        return try req.makeView("invigilator/admin/cms/page/edit", "cmsPages", [
            "page": page
        ])
    }

    func update(_ req: Request) throws -> ResponseRepresentable {
        let page = try req.parameters.next(CmsPage.self)

        try page.update(for: req)
        try page.save()

        return Response(redirect: "/admin/cms/pages").flash(.success, "Page updated")
    }

    func delete(_ req: Request) throws -> ResponseRepresentable {
        let page = try req.parameters.next(CmsPage.self)

        try page.delete()

        return Response(redirect: "/admin/cms/pages").flash(.success, "Page deleted")
    }
}