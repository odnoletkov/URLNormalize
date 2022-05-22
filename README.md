# URLNormalize

[Normalize](https://en.wikipedia.org/wiki/URI_normalization) a URL


```swift
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
```

See available [normalization options](https://github.com/odnoletkov/URLNormalize/blob/c5f48474cdaa4e20f1c8e7422ee12e9ef9ca1548/Sources/URLNormalize/URLNormalize.swift#L15-L100).

## References

* https://en.wikipedia.org/wiki/URI_normalization
* https://github.com/sindresorhus/normalize-url
