import XCTest
@testable import URLNormalize

final class URLNormalizeTests: XCTestCase {
    
    /// https://en.wikipedia.org/wiki/URI_normalization
    func testWiki() throws {
        
        // Normalizations that preserve semantics
        
        // Converting percent-encoded triplets to uppercase
        XCTAssertEqual(
            URL(string: "http://example.com/foo%2a")!.normalized(options: .percentEncodings)!.absoluteString,
            "http://example.com/foo*"
        )
        XCTAssertEqual(
            URL(string: "http://us%2fer:pass%2fword@ex%2fample.com/foo%3b?qu%5eery#frag%5ement")!.normalized(options: .percentEncodings)!.absoluteString,
            "http://us%2Fer:pass%2Fword@ex%2Fample.com/foo%3B?qu%5Eery#frag%5Ement"
        )
        
        // Converting the scheme and host to lowercase
        XCTAssertEqual(
            URL(string: "HTTP://User@Example.COM/Foo")!.normalized(options: .schemeAndHostCase)!.absoluteString,
            "http://User@example.com/Foo"
        )
        
        // Decoding percent-encoded triplets of unreserved characters
        XCTAssertEqual(
            URL(string: "http://example.com/%7Efoo")!.normalized(options: .percentEncodings)!.absoluteString,
            "http://example.com/~foo"
        )
        
        // Removing dot-segments
        XCTAssertEqual(
            URL(string: "http://example.com/foo/./bar/baz/../qux")!.normalized(options: .dotSegments)!.absoluteString,
            "http://example.com/foo/bar/qux"
        )
        
        // Converting an empty path to a "/" path
        XCTAssertEqual(
            URL(string: "http://example.com")!.normalized(options: .emptyPath)!.absoluteString,
            "http://example.com/"
        )
        XCTAssertEqual(
            URL(string: "http://")!.normalized(options: .emptyPath)!.absoluteString,
            "http://"
        )
        
        // Removing the default port
        XCTAssertEqual(
            URL(string: "http://example.com:80/")!.normalized(options: .defaultPort)!.absoluteString,
            "http://example.com/"
        )
        
        
        // Normalizations that usually preserve semantics
        
        // Adding a trailing "/" to a non-empty path
        XCTAssertEqual(
            URL(string: "http://example.com/foo")!.normalized(options: .addingTrailingSlash)!.absoluteString,
            "http://example.com/foo/"
        )
        
        
        // Normalizations that change semantics
        
        // Removing directory index
        
        // Removing the fragment
        XCTAssertEqual(
            URL(string: "http://example.com/bar.html#section1")!.normalized(options: .removingFragment)!.absoluteString,
            "http://example.com/bar.html"
        )
        
        // Replacing IP with domain name
        
        // Limiting protocols
        
        // Removing duplicate slashes
        XCTAssertEqual(
            URL(string: "http://example.com/foo//bar.html")!.normalized(options: .removingDuplicateSlashes)!.absoluteString,
            "http://example.com/foo/bar.html"
        )
        XCTAssertEqual(
            URL(string: "http://example.com/")!.normalized(options: .removingDuplicateSlashes)!.absoluteString,
            "http://example.com/"
        )
        XCTAssertEqual(
            URL(string: "http://example.com//")!.normalized(options: .removingDuplicateSlashes)!.absoluteString,
            "http://example.com/"
        )
        XCTAssertEqual(
            URL(string: "http://example.com/foo////bar/")!.normalized(options: .removingDuplicateSlashes)!.absoluteString,
            "http://example.com/foo/bar/"
        )
    }
}

extension URL {
    func normalized(options: URLComponents.Normalization) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.normalize(options: options)
        return components.url
    }
}

extension URLComponents {
    var hasAuthority: Bool {
        user?.isEmpty == false || password?.isEmpty == false || host?.isEmpty == false || port != nil
    }
}

extension URLComponents {
    
    struct Normalization: OptionSet {
        
        let rawValue: Int
        
        /// Normalizations that preserve semantics
        
        /// Converting percent-encoded triplets to uppercase,
        /// Decoding percent-encoded triplets of unreserved characters
        static let percentEncodings = Self(rawValue: 1 << 0)
        
        /// Converting the scheme and host to lowercase
        static let schemeAndHostCase = Self(rawValue: 1 << 1)
        
        /// Removing dot-segments
        static let dotSegments = Self(rawValue: 1 << 2)
        
        /// Converting an empty path to a "/" path
        static let emptyPath = Self(rawValue: 1 << 3)
        
        /// Removing the default port
        static let defaultPort = Self(rawValue: 1 << 4)
        
        
        /// Normalizations that usually preserve semantics
        
        /// Adding a trailing "/" to a non-empty path
        static let addingTrailingSlash = Self(rawValue: 1 << 5)
        
        
        /// Normalizations that change semantics
        
        /// Removing the fragment
        static let removingFragment = Self(rawValue: 1 << 6)
        
        /// Removing duplicate slashes
        static let removingDuplicateSlashes = Self(rawValue: 1 << 7)
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
    }
}
