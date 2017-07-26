///
/// File inspired by BlogUser.swift from SteamPress by 0xtim
///

import Vapor
import FluentProvider
import AuthProvider
import BCrypt
import Foundation

// MARK: - Model

final class User: Model {

    struct Properties {
        static let id = "id"
        static let name = "name"
        static let username = "username"
        static let password = "password"
        static let resetPasswordRequired = "reset_password_required"
        static let profilePicture = "profile_picture"
        static let twitterHandle = "twitter_handle"
        static let biography = "biography"
        static let tagline = "tagline"
        static let postCount = "post_count"
    }

    let storage = Storage()

    var name: String
    var username: String
    var password: Bytes
    var resetPasswordRequired: Bool = false
    var profilePicture: String?
    var twitterHandle: String?
    var biography: String?
    var tagline: String?

    init(name: String, username: String, password: Bytes, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) {
        self.name = name
        self.username = username.lowercased()
        self.password = password
        self.profilePicture = profilePicture
        self.twitterHandle = twitterHandle
        self.biography = biography
        self.tagline = tagline
    }

    init(row: Row) throws {
        name = try row.get(Properties.name)
        username = try row.get(Properties.username)
        let passwordAsString: String = try row.get(Properties.password)
        password = passwordAsString.makeBytes()
        resetPasswordRequired = try row.get(Properties.resetPasswordRequired)
        profilePicture = try? row.get(Properties.profilePicture)
        twitterHandle = try? row.get(Properties.twitterHandle)
        biography = try? row.get(Properties.biography)
        tagline = try? row.get(Properties.tagline)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.name, name)
        try row.set(Properties.username, username)
        try row.set(Properties.password, password.makeString())
        try row.set(Properties.resetPasswordRequired, resetPasswordRequired)
        try row.set(Properties.profilePicture, profilePicture)
        try row.set(Properties.twitterHandle, twitterHandle)
        try row.set(Properties.biography, biography)
        try row.set(Properties.tagline, tagline)
        return row
    }
}

// MARK: Preparation
extension User: Preparation {
    public static func prepare(_ database: Fluent.Database) throws {
        try database.create(self) { users in
            users.id()
            users.string(Properties.name)
            users.string(Properties.username, unique: true)
            users.string(Properties.password)
            users.bool(Properties.resetPasswordRequired)
            users.string(Properties.profilePicture, optional: true, default: nil)
            users.string(Properties.twitterHandle, optional: true, default: nil)
            users.custom(Properties.biography, type: "TEXT", optional: true, default: nil)
            users.string(Properties.tagline, optional: true, default: nil)
        }
    }

    public static func revert(_ database: Fluent.Database) throws {
        try database.delete(self)
    }
}

extension User: Parameterizable {}

// MARK: - Node

extension User: NodeRepresentable {

    func makeNode(in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set(Properties.id, id)
        try node.set(Properties.name, name)
        try node.set(Properties.username, username)
        try node.set(Properties.resetPasswordRequired, resetPasswordRequired)

        if let profilePicture = profilePicture {
            try node.set(Properties.profilePicture, profilePicture)
        }

        if let twitterHandle = twitterHandle {
            try node.set(Properties.twitterHandle, twitterHandle)
        }

        if let biography = biography {
            try node.set(Properties.biography, biography)
        }

        if let tagline = tagline {
            try node.set(Properties.tagline, tagline)
        }

        guard let providedContext = context else {
            return node
        }

        return node
    }

}

// MARK: - Authentication

extension User: SessionPersistable {}

extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}

extension User: PasswordAuthenticatable {
    public static let usernameKey = Properties.username
    public static let passwordVerifier: PasswordVerifier? = User.passwordHasher
    public var hashedPassword: String? {
        return password.makeString()
    }
    internal(set) static var passwordHasher: PasswordHasherVerifier = BCryptHasher(cost: 10)
}

protocol PasswordHasherVerifier: PasswordVerifier, HashProtocol {}

extension BCryptHasher: PasswordHasherVerifier {}

extension User: Updateable {
    public static var updateableKeys: [UpdateableKey<User>] {
        return [
            UpdateableKey("name", String.self) { user, newName in
                user.name = newName
            },

            UpdateableKey("username", String.self) { user, newUsername in
                user.username = newUsername
            },

            UpdateableKey("password", String.self) { user, newPassword in
                user.password = try User.passwordHasher.make(newPassword)
            }
        ]
    }
}