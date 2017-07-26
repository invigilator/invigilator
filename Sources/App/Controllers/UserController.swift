import Vapor
import HTTP
import AuthProvider

final class UserController {

    let view: ViewRenderer

    init(_ view: ViewRenderer) {
        self.view = view
    }

    /// GET /admin/login
    func login(_ req: Request) throws -> ResponseRepresentable {
        do {
            let users = try User.all()
            if users.count == 0 {
                let password = String.random()

                let hashedPassword = try User.passwordHasher.make(password)
                let user = User(name: "Admin", username: "admin", password: hashedPassword, profilePicture: nil, twitterHandle: nil, biography: nil, tagline: "Admin for the blog")
                user.resetPasswordRequired = true
                try user.save()

                return Response(redirect: "/admin/login").flash(.success, "An Admin user been created for you - the username is admin and the password is \(password)")
            }
        } catch {
            return Response(redirect: "/admin/login").flash(.error, "There was an error creating a new admin user: \(error)")
        }

        return try view.make("invigilator/admin/user/login", for: req)
    }

    func doLogin(_ req: Request) throws -> ResponseRepresentable {
        let username = req.data["username"]?.string ?? ""
        let password = req.data["password"]?.string ?? ""

        let passwordCredentials = Password(username: username.lowercased(), password: password)

        do {
            let user = try User.authenticate(passwordCredentials)
            req.auth.authenticate(user)

            var redirect = "/admin"
            if let next: String = req.query?["next"]?.string, !next.isEmpty {
                redirect = next
            }

            return Response(redirect: redirect).flash(.success, "Login success")
        } catch {
            return Response(redirect: "/admin/login").flash(.error, "Invalid username or password")
        }
    }

    func logout(_ req: Request) throws -> ResponseRepresentable {
        try req.auth.unauthenticate()
        return Response(redirect: "/admin/login").flash(.success, "You are now logged out")
    }

    func index(_ req: Request) throws -> ResponseRepresentable {
        let users = try User.all()

        return try req.makeView("invigilator/admin/user/index", "users", [
            "users": users
        ])
    }

    func create(_ req: Request) throws -> ResponseRepresentable {
        return try view.make("invigilator/admin/user/create", for: req)
    }

    func edit(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)

        return try req.makeView("invigilator/admin/user/edit", "users", [
            "user": user
        ])
    }

    func update(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)

        try user.update(for: req)
        try user.save()

        return Response(redirect: "/admin").flash(.success, "User updated")
    }
}

extension String {

    // TODO Could probably improve this
    static func random(length: Int = 8) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            let randomValue = Int.random(min: 0, max: base.characters.count-1)
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }

}