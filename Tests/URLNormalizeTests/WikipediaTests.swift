import XCTest
@testable import URLNormalize

final class WikipediaTests: XCTestCase {
    
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
                .normalized(options: .lowercaseSchemeAndHost).string!,
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
                .normalized(options: .removeDotSegments).string!,
            "http://example.com/foo/bar/qux"
        )
        
        // Converting an empty path to a "/" path
        XCTAssertEqual(
            URLComponents(string: "http://example.com")!
                .normalized(options: .convertEmptyPath).string!,
            "http://example.com/"
        )
        XCTAssertEqual(
            URLComponents(string: "http://")!
                .normalized(options: .convertEmptyPath).string!,
            "http://"
        )
        
        // Removing the default port
        XCTAssertEqual(
            URLComponents(string: "http://example.com:80/")!
                .normalized(options: .removeDefaultPort).string!,
            "http://example.com/"
        )
        
        
        // Normalizations that usually preserve semantics
        
        // Adding a trailing "/" to a non-empty path
        XCTAssertEqual(
            URLComponents(string: "http://example.com/foo")!
                .normalized(options: .addTrailingSlash).string!,
            "http://example.com/foo/"
        )
        
        
        // Normalizations that change semantics
        
        // Removing directory index
        
        // Removing the fragment
        XCTAssertEqual(
            URLComponents(string: "http://example.com/bar.html#section1")!
                .normalized(options: .removeFragment).string!,
            "http://example.com/bar.html"
        )
        
        // Replacing IP with domain name
        
        // Limiting protocols
        
        // Removing duplicate slashes
        XCTAssertEqual(
            URLComponents(string: "http://example.com/foo//bar.html")!
                .normalized(options: .removeDuplicateSlashes).string!,
            "http://example.com/foo/bar.html"
        )
        XCTAssertEqual(
            URLComponents(string: "http://example.com/")!
                .normalized(options: .removeDuplicateSlashes).string!,
            "http://example.com/"
        )
        XCTAssertEqual(
            URLComponents(string: "http://example.com//")!
                .normalized(options: .removeDuplicateSlashes).string!,
            "http://example.com/"
        )
        XCTAssertEqual(
            URLComponents(string: "http://example.com/foo////bar/")!
                .normalized(options: .removeDuplicateSlashes).string!,
            "http://example.com/foo/bar/"
        )
        
        // Removing or adding “www” as the first domain label
        
        // Sorting the query parameters
        XCTAssertEqual(
            URLComponents(string: "http://example.com/display?lang=en&article=fred")!
                .normalized(options: .sortQueryParameters).string!,
            "http://example.com/display?article=fred&lang=en"
        )
        
        // Removing unused query variables
        
        // Removing default query parameters
        
        // Removing the "?" when the query is empty
        XCTAssertEqual(
            URLComponents(string: "http://example.com/display?")!
                .normalized(options: .removeEmptyQuery).string!,
            "http://example.com/display"
        )
    }
}
