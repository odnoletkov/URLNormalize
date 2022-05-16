import XCTest
@testable import URLNormalize

final class URLNormalizeTests: XCTestCase {

    /// https://en.wikipedia.org/wiki/URI_normalization
    func testWiki() throws {

        // Converting percent-encoded triplets to uppercase
        XCTAssertEqual(
            URL(string: "http://example.com/foo%2a")!.normalized!.absoluteString,
            "http://example.com/foo*"
        )
        XCTAssertEqual(
            URL(string: "http://us%2fer:pass%2fword@ex%2fample.com/foo%3b?qu%5eery#frag%5ement")!.normalized!.absoluteString,
            "http://us%2Fer:pass%2Fword@ex%2Fample.com/foo%3B?qu%5Eery#frag%5Ement"
        )

        // Converting the scheme and host to lowercase
        XCTAssertEqual(
            URL(string: "HTTP://User@Example.COM/Foo")!.normalized!.absoluteString,
            "http://User@example.com/Foo"
        )

        // Decoding percent-encoded triplets of unreserved characters
        XCTAssertEqual(
            URL(string: "http://example.com/%7Efoo")!.normalized!.absoluteString,
            "http://example.com/~foo"
        )

    }
}

extension URL {
    var normalized: URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.normalizePercentEncodings()
        components.normalizeSchemeAndHostCase()
        return components.url
    }
}

extension URLComponents {
    mutating func normalizePercentEncodings() {
        user = user
        password = password
        host = host
        path = path
        query = query
        fragment = fragment
    }

    mutating func normalizeSchemeAndHostCase() {
        scheme = scheme?.lowercased()
        host = host?.lowercased()
    }
}
