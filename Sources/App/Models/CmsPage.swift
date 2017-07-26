import Foundation
import Vapor
import FluentProvider

// MARK: - Model
public final class CmsPage: Model {
    struct Properties {
        static let id = "id"
        static let title = "title"
        static let contents = "contents"
        static let created = "created"
        static let createdDate = "created_date"
        static let createdDateIso8601 = "created_date_iso8601"
        static let lastEdited = "last_edited"
        static let slugUrl = "slug_url"
        static let published = "published"
        static let metaTitle = "meta_title"
        static let metaKeywords = "meta_keywords"
        static let metaDescription = "meta_description"
    }

    public let storage = Storage()

    public var title: String
    public var contents: String
    public var created: Date
    public var lastEdited: Date?
    public var slugUrl: String
    public var published: Bool
    public var metaTitle: String?
    public var metaKeywords: String?
    public var metaDescription: String?

    init(title: String, contents: String, creationDate: Date, slugUrl: String, published: Bool, metaTitle: String?, metaKeywords: String?, metaDescription: String?) {
        self.title = title
        self.contents = contents
        self.created = creationDate
        self.slugUrl = CmsPage.generateUniqueSlugUrl(from: slugUrl)
        self.lastEdited = nil
        self.published = published
        self.metaTitle = metaTitle
        self.metaKeywords = metaKeywords
        self.metaDescription = metaDescription
    }

    public required init(row: Row) throws {
        title = try row.get(Properties.title)
        contents = try row.get(Properties.contents)
        slugUrl = try row.get(Properties.slugUrl)
        published = try row.get(Properties.published)
        let createdTime: Double = try row.get(Properties.created)
        let lastEditedTime: Double? = try? row.get(Properties.lastEdited)
        metaTitle = try? row.get(Properties.metaTitle)
        metaKeywords = try? row.get(Properties.metaKeywords)
        metaDescription = try? row.get(Properties.metaDescription)

        created = Date(timeIntervalSince1970: createdTime)

        if let lastEditedTime = lastEditedTime {
            lastEdited = Date(timeIntervalSince1970: lastEditedTime)
        }
    }

    public func makeRow() throws -> Row {
        let createdTime = created.timeIntervalSince1970

        var row = Row()
        try row.set(Properties.title, title)
        try row.set(Properties.contents, contents)
        try row.set(Properties.created, createdTime)
        try row.set(Properties.slugUrl, slugUrl)
        try row.set(Properties.published, published)
        try row.set(Properties.lastEdited, lastEdited?.timeIntervalSince1970)
        try row.set(Properties.metaTitle, metaTitle)
        try row.set(Properties.metaKeywords, metaKeywords)
        try row.set(Properties.metaDescription, metaDescription)
        return row
    }
}

extension CmsPage: Preparation {

    public static func prepare(_ database: Database) throws {
        try database.create(self) { pages in
            pages.id()
            pages.string(Properties.title)
            pages.custom(Properties.contents, type: "TEXT")
            pages.double(Properties.created)
            pages.double(Properties.lastEdited, optional: true)
            pages.string(Properties.slugUrl, unique: true)
            pages.bool(Properties.published, optional: false, default: true)
            pages.string(Properties.metaTitle, optional: true)
            pages.string(Properties.metaKeywords, optional: true)
            pages.string(Properties.metaDescription, optional: true)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension CmsPage: Parameterizable {}

// MARK: - Node

extension CmsPage: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        let createdTime = created.timeIntervalSince1970

        var node = Node([:], in: context)
        try node.set(Properties.id, id)
        try node.set(Properties.title, title)
        try node.set(Properties.contents, contents)
        try node.set(Properties.created, createdTime)
        try node.set(Properties.slugUrl, slugUrl)
        try node.set(Properties.published, published)
        try node.set(Properties.metaTitle, metaTitle)
        try node.set(Properties.metaKeywords, metaKeywords)
        try node.set(Properties.metaDescription, metaDescription)

        if let lastEdited = lastEdited {
            try node.set(Properties.lastEdited, lastEdited.timeIntervalSince1970)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        let createdDate = dateFormatter.string(from: created)

        try node.set(Properties.createdDate, createdDate)

        return node
    }
}

// MARK: - CmsPage Utilities

extension CmsPage {
    static func generateUniqueSlugUrl(from title: String) -> String {
        let alphanumericsWithHyphenAndSpace = CharacterSet(charactersIn: " -0123456789abcdefghijklmnopqrstuvwxyz")

        let slugUrl = title.lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: alphanumericsWithHyphenAndSpace.inverted).joined()
                .components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
                .replacingOccurrences(of: " ", with: "-", options: .regularExpression)

        var newSlugUrl = slugUrl
        var count = 2

        do {
            while try CmsPage.makeQuery().filter(Properties.slugUrl, newSlugUrl).first() != nil {
                newSlugUrl = "\(slugUrl)-\(count)"
                count += 1
            }
        } catch {
            // Swallow error - this will propragate the error up to the DB driver which should fail if it is not unique
        }

        return newSlugUrl
    }
}

extension CmsPage: Updateable {
    public static var updateableKeys: [UpdateableKey<CmsPage>] {
        return [
            UpdateableKey("title", String.self) { page, newTitle in
                page.title = newTitle
            },

            UpdateableKey.init("slugUrl", String.self) { page, newSlugUrl in
                if page.slugUrl != newSlugUrl {
                    page.slugUrl = CmsPage.generateUniqueSlugUrl(from: newSlugUrl)
                }
            },

            UpdateableKey("contents", String.self) { page, newContents in
                page.contents = newContents
            }
        ]
    }
}