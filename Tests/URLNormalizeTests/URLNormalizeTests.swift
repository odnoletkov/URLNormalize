import XCTest
@testable import URLNormalize

final class URLNormalizeTests: XCTestCase {
    
    /// https://en.wikipedia.org/wiki/URI_normalization
    func testWiki() throws {
        
        // Normalizations that preserve semantics
        
        // Converting percent-encoded triplets to uppercase
        XCTAssertEqual(
            URLComponents(string: "http://example.com/foo%2a")!
                .normalized(options: .percentEncodings).string!,
            "http://example.com/foo*"
        )
        XCTAssertEqual(
            URLComponents(string: "http://us%2fer:pass%2fword@ex%2fample.com/foo%3b?qu%5eery#frag%5ement")!
                .normalized(options: .percentEncodings).string!,
            "http://us%2Fer:pass%2Fword@ex%2Fample.com/foo%3B?qu%5Eery#frag%5Ement"
        )
        
        // Converting the scheme and host to lowercase
        XCTAssertEqual(
            URLComponents(string: "HTTP://User@Example.COM/Foo")!
                .normalized(options: .schemeAndHostCase).string!,
            "http://User@example.com/Foo"
        )
        
        // Decoding percent-encoded triplets of unreserved characters
        XCTAssertEqual(
            URLComponents(string: "http://example.com/%7Efoo")!
                .normalized(options: .percentEncodings).string!,
            "http://example.com/~foo"
        )
        
        // Removing dot-segments
        XCTAssertEqual(
            URLComponents(string: "http://example.com/foo/./bar/baz/../qux")!
                .normalized(options: .dotSegments).string!,
            "http://example.com/foo/bar/qux"
        )
        
        // Converting an empty path to a "/" path
        XCTAssertEqual(
            URLComponents(string: "http://example.com")!
                .normalized(options: .emptyPath).string!,
            "http://example.com/"
        )
        XCTAssertEqual(
            URLComponents(string: "http://")!
                .normalized(options: .emptyPath).string!,
            "http://"
        )
        
        // Removing the default port
        XCTAssertEqual(
            URLComponents(string: "http://example.com:80/")!
                .normalized(options: .defaultPort).string!,
            "http://example.com/"
        )
        
        
        // Normalizations that usually preserve semantics
        
        // Adding a trailing "/" to a non-empty path
        XCTAssertEqual(
            URLComponents(string: "http://example.com/foo")!
                .normalized(options: .addingTrailingSlash).string!,
            "http://example.com/foo/"
        )
        
        
        // Normalizations that change semantics
        
        // Removing directory index
        
        // Removing the fragment
        XCTAssertEqual(
            URLComponents(string: "http://example.com/bar.html#section1")!
                .normalized(options: .removingFragment).string!,
            "http://example.com/bar.html"
        )
        
        // Replacing IP with domain name
        
        // Limiting protocols
        
        // Removing duplicate slashes
        XCTAssertEqual(
            URLComponents(string: "http://example.com/foo//bar.html")!
                .normalized(options: .removingDuplicateSlashes).string!,
            "http://example.com/foo/bar.html"
        )
        XCTAssertEqual(
            URLComponents(string: "http://example.com/")!
                .normalized(options: .removingDuplicateSlashes).string!,
            "http://example.com/"
        )
        XCTAssertEqual(
            URLComponents(string: "http://example.com//")!
                .normalized(options: .removingDuplicateSlashes).string!,
            "http://example.com/"
        )
        XCTAssertEqual(
            URLComponents(string: "http://example.com/foo////bar/")!
                .normalized(options: .removingDuplicateSlashes).string!,
            "http://example.com/foo/bar/"
        )
        
        // Removing or adding “www” as the first domain label
        
        // Sorting the query parameters
        XCTAssertEqual(
            URLComponents(string: "http://example.com/display?lang=en&article=fred")!
                .normalized(options: .sortingQueryParameters).string!,
            "http://example.com/display?article=fred&lang=en"
        )
        
        // Removing unused query variables
        
        // Removing default query parameters
        
        // Removing the "?" when the query is empty
        XCTAssertEqual(
            URLComponents(string: "http://example.com/display?")!
                .normalized(options: .removingEmptyQuery).string!,
            "http://example.com/display"
        )
    }
    
    /// https://github.com/sindresorhus/normalize-url
    func testJSNormalize() {
        XCTAssertEqual(
            URLComponents(string: "https://sindresorhus.com")!
                .normalized(options: .forceHTTP).string!,
            "http://sindresorhus.com"
        )
        XCTAssertEqual(
            URLComponents(string: "http://sindresorhus.com")!
                .normalized(options: .forceHTTPS).string!,
            "https://sindresorhus.com"
        )
        XCTAssertEqual(
            URLComponents(string: "http://user:password@sindresorhus.com")!
                .normalized(options: .stripAuthentication).string!,
            "http://sindresorhus.com"
        )
        XCTAssertEqual(
            URLComponents(string: "https://sindresorhus.com")!
                .normalized(options: .stripProtocol).string!,
            "//sindresorhus.com"
        )
        XCTAssertEqual(
            URLComponents(string: "http://www.sindresorhus.com")!
                .normalized(options: .stripWWW).string!,
            "http://sindresorhus.com"
        )
        XCTAssertEqual(
            URLComponents(string: "www.sindresorhus.com?foo=bar")!
                .normalized(options: .removeQueryParameters).string!,
            "www.sindresorhus.com"
        )
        XCTAssertEqual(
            URLComponents(string: "http://sindresorhus.com/redirect/")!
                .normalized(options: .removeTrailingSlash).string!,
            "http://sindresorhus.com/redirect"
        )
        XCTAssertEqual(
            URLComponents(string: "http://sindresorhus.com/")!
                .normalized(options: .removeTrailingSlash).string!,
            "http://sindresorhus.com"
        )
    }
}

extension URLComponents {
    func normalized(options: Normalization) -> URLComponents {
        var result = self
        result.normalize(options: options)
        return result
    }

    var hasAuthority: Bool {
        user?.isEmpty == false || password?.isEmpty == false || host?.isEmpty == false || port != nil
    }
}

extension URLComponents {
    struct Normalization: OptionSet {
        
        let rawValue: Int
        
        /// Normalizations that preserve semantics:
        
        /// Converting percent-encoded triplets to uppercase.
        /// Decoding percent-encoded triplets of unreserved characters.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let percentEncodings = Self(rawValue: 1 << 0)
        
        /// Converting the scheme and host to lowercase.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let schemeAndHostCase = Self(rawValue: 1 << 1)
        
        /// Removing dot-segments.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let dotSegments = Self(rawValue: 1 << 2)
        
        /// Converting an empty path to a "/" path.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let emptyPath = Self(rawValue: 1 << 3)
        
        /// Removing the default port.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let defaultPort = Self(rawValue: 1 << 4)
        
        
        /// Normalizations that usually preserve semantics:
        
        /// Adding a trailing "/" to a non-empty path.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let addingTrailingSlash = Self(rawValue: 1 << 5)
        
        
        /// Normalizations that change semantics:
        
        /// Removing the fragment.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let removingFragment = Self(rawValue: 1 << 6)
        
        /// Removing duplicate slashes.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let removingDuplicateSlashes = Self(rawValue: 1 << 7)
        
        /// Sorting the query parameters.
        /// Not guaranteed to be stable!
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let sortingQueryParameters = Self(rawValue: 1 << 8)
        
        /// Removing the "?" when the query is empty.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let removingEmptyQuery = Self(rawValue: 1 << 9)
        

        /// JS normalizations:
        
        /// Force HTTP
        /// From https://github.com/sindresorhus/normalize-url
        static let forceHTTP = Self(rawValue: 1 << 10)
        
        /// Force HTTP
        /// From https://github.com/sindresorhus/normalize-url
        static let forceHTTPS = Self(rawValue: 1 << 11)
        
        /// Strip authentication
        /// From https://github.com/sindresorhus/normalize-url
        static let stripAuthentication = Self(rawValue: 1 << 12)
        
        /// Strip protocol (only http and https)
        /// From https://github.com/sindresorhus/normalize-url
        static let stripProtocol = Self(rawValue: 1 << 13)
        
        /// Strip www
        /// From https://github.com/sindresorhus/normalize-url
        static let stripWWW = Self(rawValue: 1 << 14)
        
        /// Remove query parameters
        /// From https://github.com/sindresorhus/normalize-url
        static let removeQueryParameters = Self(rawValue: 1 << 15)
        
        /// Remove trailing slash
        /// From https://github.com/sindresorhus/normalize-url
        static let removeTrailingSlash = Self(rawValue: 1 << 16)
    }
    
    mutating func normalize(options: Normalization) {
        if options.contains(.percentEncodings) {
            user = user
            password = password
            host = host
            path = path
            query = query
            fragment = fragment
        }
        
        if options.contains(.schemeAndHostCase) {
            scheme = scheme?.lowercased()
            host = host?.lowercased()
        }
        
        if options.contains(.dotSegments) {
            if !path.isEmpty, let url = url, let cmps = URLComponents(url: url.standardized, resolvingAgainstBaseURL: false) {
                self = cmps
            }
        }
        
        if options.contains(.emptyPath) {
            if hasAuthority && path == "" {
                path = "/"
            }
        }
        
        if options.contains(.defaultPort) {
            if scheme == "http" || scheme == "https", port == 80 {
                port = nil
            }
        }
        
        if options.contains(.addingTrailingSlash) {
            if path.last != "/" {
                path += "/"
            }
        }
        
        if options.contains(.removingFragment) {
            fragment = nil
        }
        
        if options.contains(.removingDuplicateSlashes) {
            if path != "/" {
                path = (path as NSString)
                    .pathComponents
                    .map { $0 == "/" ? "" : $0 }
                    .joined(separator: "/")
            }
        }
        
        if options.contains(.sortingQueryParameters) {
            queryItems = queryItems.map {
                $0.sorted { $0.name < $1.name }
            }
        }
        
        if options.contains(.removingEmptyQuery) {
            if query == "" {
                query = nil
            }
        }
        
        if options.contains(.forceHTTP) {
            if scheme == "https" {
                scheme = "http"
            }
        }
        
        if options.contains(.forceHTTPS) {
            if scheme == "http" {
                scheme = "https"
            }
        }
        
        if options.contains(.stripAuthentication) {
            user = nil
            password = nil
        }
        
        if options.contains(.stripProtocol) {
            if scheme == "http" || scheme == "https" {
                scheme = nil
            }
        }
        
        if options.contains(.stripWWW) {
            if host?.hasPrefix("www.") ?? false {
                host?.removeFirst(4)
            }
        }
        
        if options.contains(.removeQueryParameters) {
            query = nil
        }
        
        if options.contains(.removeTrailingSlash) {
            if path.last == "/" {
                path.removeLast()
            }
        }
    }
}
