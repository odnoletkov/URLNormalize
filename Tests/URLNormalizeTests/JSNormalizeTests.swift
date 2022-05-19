import XCTest
@testable import URLNormalize

extension URLComponents.Normalization {
    static let JSDefaults: Self = [
        .normalizeProtocol,
        .stripAuthentication,
        .stripWWW,
        .removeTrailingSlash,
        .sortQueryParameters,
        
        .lowercaseSchemeAndHost,
        .removeDefaultPort,
        .removeDuplicateSlashes,
        .removeEmptyQuery,
        .removeDotSegments,
    ]
}

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
        XCTAssertEqual(
            URLComponents(string: "//sindresorhus.com:80/")!
                .normalized(options: .normalizeProtocol).string!,
            "http://sindresorhus.com:80/"
        )
    }
    
    func test() {
        XCTAssertEqual(URLComponents(string: "//sindresorhus.com")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com")
        XCTAssertNil(URLComponents(string: "sindresorhus.com "))
        XCTAssertEqual(URLComponents(string: "//sindresorhus.com.")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com.")
        XCTAssertEqual(URLComponents(string: "//SindreSorhus.com")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com")
//        XCTAssertEqual(URLComponents(string: "//sindresorhus.com")!.normalized(options: .JSDefaults.union(.forceHTTPS)).string!, "https://sindresorhus.com")
        XCTAssertEqual(URLComponents(string: "HTTP://sindresorhus.com")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com")
        XCTAssertEqual(URLComponents(string: "//sindresorhus.com")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com")
        XCTAssertEqual(URLComponents(string: "http://sindresorhus.com")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com")
        XCTAssertEqual(URLComponents(string: "http://sindresorhus.com:80")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com")
//        XCTAssertEqual(URLComponents(string: "https://sindresorhus.com:443")!.normalized(options: .JSDefaults).string!, "https://sindresorhus.com")
//        XCTAssertEqual(URLComponents(string: "ftp://sindresorhus.com:21")!.normalized(options: .JSDefaults).string!, "ftp://sindresorhus.com")
        XCTAssertEqual(URLComponents(string: "http://www.sindresorhus.com")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com")
//        XCTAssertEqual(URLComponents(string: "//www.com")!.normalized(options: .JSDefaults).string!, "http://www.com")
//        XCTAssertEqual(URLComponents(string: "http://www.www.sindresorhus.com")!.normalized(options: .JSDefaults).string!, "http://www.www.sindresorhus.com")
        XCTAssertEqual(URLComponents(string: "//www.sindresorhus.com")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com")
        XCTAssertEqual(URLComponents(string: "http://sindresorhus.com/foo/")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com/foo")
        XCTAssertNil(URLComponents(string: "sindresorhus.com/?foo=bar baz"))
//        XCTAssertEqual(URLComponents(string: "https://foo.com/https://bar.com")!.normalized(options: .JSDefaults).string!, "https://foo.com/https://bar.com")
//        XCTAssertEqual(URLComponents(string: "https://foo.com/https://bar.com/foo//bar")!.normalized(options: .JSDefaults).string!, "https://foo.com/https://bar.com/foo/bar")
//        XCTAssertEqual(URLComponents(string: "https://foo.com/http://bar.com")!.normalized(options: .JSDefaults).string!, "https://foo.com/http://bar.com")
//        XCTAssertEqual(URLComponents(string: "https://foo.com/http://bar.com/foo//bar")!.normalized(options: .JSDefaults).string!, "https://foo.com/http://bar.com/foo/bar")
        XCTAssertEqual(URLComponents(string: "http://sindresorhus.com/%7Efoo/")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com/~foo")
        XCTAssertNil(URLComponents(string: "https://foo.com/%FAIL%/07/94/ca/55.jpg"))
        XCTAssertEqual(URLComponents(string: "http://sindresorhus.com/?")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com")
        XCTAssertNil(URLComponents(string: "êxample.com"))
        XCTAssertEqual(URLComponents(string: "http://sindresorhus.com/?b=bar&a=foo")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com?a=foo&b=bar")
        XCTAssertNil(URLComponents(string: "http://sindresorhus.com/?foo=bar*|<>:\""))
        XCTAssertEqual(URLComponents(string: "http://sindresorhus.com:5000")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com:5000")
        XCTAssertEqual(URLComponents(string: "//sindresorhus.com/")!.normalized(options: .JSDefaults.subtracting(.normalizeProtocol)).string!, "sindresorhus.com")
        XCTAssertEqual(URLComponents(string: "//sindresorhus.com:80/")!.normalized(options: .JSDefaults.subtracting(.normalizeProtocol)).string!, "sindresorhus.com:80")
        XCTAssertEqual(URLComponents(string: "http://sindresorhus.com/foo#bar")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com/foo#bar")
        XCTAssertEqual(URLComponents(string: "http://sindresorhus.com/foo#bar")!.normalized(options: .JSDefaults.union(.removeFragment)).string!, "http://sindresorhus.com/foo")
        XCTAssertEqual(URLComponents(string: "http://sindresorhus.com/foo#bar:~:text=hello%20world")!.normalized(options: .JSDefaults.union(.removeFragment)).string!, "http://sindresorhus.com/foo")
        XCTAssertEqual(URLComponents(string: "http://sindresorhus.com/foo/bar/../baz")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com/foo/baz")
        XCTAssertEqual(URLComponents(string: "http://sindresorhus.com/foo/bar/./baz")!.normalized(options: .JSDefaults).string!, "http://sindresorhus.com/foo/bar/baz")
        XCTAssertEqual(URLComponents(string: "sindre://www.sorhus.com")!.normalized(options: .JSDefaults).string!, "sindre://sorhus.com")
        XCTAssertEqual(URLComponents(string: "sindre://www.sorhus.com/")!.normalized(options: .JSDefaults).string!, "sindre://sorhus.com")
        XCTAssertEqual(URLComponents(string: "sindre://www.sorhus.com/foo/bar")!.normalized(options: .JSDefaults).string!, "sindre://sorhus.com/foo/bar")
        XCTAssertEqual(URLComponents(string: "https://i.vimeocdn.com/filter/overlay?src0=https://i.vimeocdn.com/video/598160082_1280x720.jpg&src1=https://f.vimeocdn.com/images_v6/share/play_icon_overlay.png")!.normalized(options: .JSDefaults).string!, "https://i.vimeocdn.com/filter/overlay?src0=https://i.vimeocdn.com/video/598160082_1280x720.jpg&src1=https://f.vimeocdn.com/images_v6/share/play_icon_overlay.png")
    }
}
