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

        // Removing dot-segments
        XCTAssertEqual(
            URL(string: "http://example.com/foo/./bar/baz/../qux")!.normalized!.absoluteString,
            "http://example.com/foo/bar/qux"
        )

        // Converting an empty path to a "/" path
        XCTAssertEqual(
            URL(string: "http://example.com")!.normalized!.absoluteString,
            "http://example.com/"
        )
        XCTAssertEqual(
            URL(string: "http://")!.normalized!.absoluteString,
            "http://"
        )

        // Removing the default port
        XCTAssertEqual(
            URL(string: "http://example.com:80/")!.normalized!.absoluteString,
            "http://example.com/"
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
        components.normalizeDotSegments()
        components.normalizeEmptyPath()
        components.normalizeDefaultPort()
        return components.url
    }
}

extension URLComponents {
    var hasAuthority: Bool {
        user?.isEmpty == false || password?.isEmpty == false || host?.isEmpty == false || port != nil
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

    mutating func normalizeDotSegments() {
        if !path.isEmpty, let url = url, let cmps = URLComponents(url: url.standardized, resolvingAgainstBaseURL: false) {
            self = cmps
        }
    }

    mutating func normalizeEmptyPath() {
        if hasAuthority && path == "" {
            path = "/"
        }
    }

    mutating func normalizeDefaultPort() {
        if scheme == "http" || scheme == "https", port == 80 {
            port = nil
        }
    }
}
