import Leaf
import SwiftMarkdown

public final class InviligatorMarkdown: Tag {

    public enum Error: Swift.Error {
        case invalidArgument(Argument?)
    }

    public init() { }

    public let name = "invigilatorMarkdown"

    public func run(tagTemplate: TagTemplate, arguments: ArgumentList) throws -> Node? {
        var markdown = ""

        if let markdownArgument = arguments.first {
            guard let markdownArgumentValue = markdownArgument.string else {
                throw Error.invalidArgument(arguments.list.first)
            }
            markdown = markdownArgumentValue
        }

        var markdownHtml = try markdownToHTML(markdown)
        markdownHtml = markdownHtml.replacingOccurrences(of: "#(row)", with: "<div class=\"row\">", options: .regularExpression)
        markdownHtml = markdownHtml.replacingOccurrences(of: "#(col)=([1-9])", with: "<div class=\"col-md-$2\">", options: .regularExpression)
        markdownHtml = markdownHtml.replacingOccurrences(of: "#(/col)", with: "</div>", options: .regularExpression)
        markdownHtml = markdownHtml.replacingOccurrences(of: "#(/row)", with: "</div>", options: .regularExpression)
        let unescaped = markdownHtml.bytes
        return .bytes(unescaped)
    }
}
