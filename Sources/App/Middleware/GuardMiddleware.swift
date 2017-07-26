import HTTP
import Vapor

struct GuardMiddleware: Middleware {

    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {

        do {
            let user = try request.user()

            try request.storage["authedBackendUser"] = request.user()

        } catch {
            return Response(redirect: "/admin/login?next=" + request.uri.path).flash(.error, "Session expired login again")
        }

        return try next.respond(to: request)
    }
}
