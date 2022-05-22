import XCTest
import URLNormalize

class ReadmeTests: XCTestCase {

    func test() {
        XCTAssertEqual(
            URL(string: "HTTP://example.com/foo%2a/./bar/..//baz/?b=v&a=v")?
                .normalized().absoluteString,
            "http://example.com/foo*/baz?a=v&b=v"
        )
        
        XCTAssertEqual(
            URL(string: "http://example.com/")?
                .normalized(options: [.forceHTTPS, .removeTrailingSlash]).absoluteString,
            "https://example.com"
        )
    }
}
