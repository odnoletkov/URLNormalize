import XCTest
@testable import URLNormalize

final class JSNormalizeTests: XCTestCase {
    
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
