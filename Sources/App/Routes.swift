import Vapor

final class Routes: RouteCollection {
    let view: ViewRenderer
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        let adminRouter = builder.grouped("admin")
        let guarded = GuardMiddleware()
        let guardedRoutes = adminRouter.grouped(guarded)

        // MARK: - User
        let userController = UserController(view)
        adminRouter.get("login", handler: userController.login)
        adminRouter.post("login", handler: userController.doLogin)
        guardedRoutes.get("logout", handler: userController.logout)
        guardedRoutes.get("users", handler: userController.index)
        guardedRoutes.get("users/create", handler: userController.create)
        guardedRoutes.get("users", User.parameter, "edit", handler: userController.edit)
        guardedRoutes.post("users", User.parameter, "edit", handler: userController.update)

        // MARK: - Dashboard
        let dashboardController = DashboardController(view)
        guardedRoutes.get(handler: dashboardController.index)

        // MARK: - CMS Page
        let cmsPageController = CmsPageController(view)

        let cmsRouter = builder.grouped("")
        cmsRouter.get(String.parameter, handler: cmsPageController.view)

        guardedRoutes.get("cms/pages", handler: cmsPageController.index)
        guardedRoutes.get("cms/pages/create", handler: cmsPageController.create)
        guardedRoutes.post("cms/pages/create", handler: cmsPageController.store)
        guardedRoutes.get("cms/pages", CmsPage.parameter, "edit", handler: cmsPageController.edit)
        guardedRoutes.post("cms/pages", CmsPage.parameter, "edit", handler: cmsPageController.update)
        guardedRoutes.get("cms/pages", CmsPage.parameter, "delete", handler: cmsPageController.delete)

        // MARK: - CMS Menu
        let cmsMenuController = CmsMenuController(view)
        guardedRoutes.get("cms/menus", handler: cmsMenuController.index)
    }
}
