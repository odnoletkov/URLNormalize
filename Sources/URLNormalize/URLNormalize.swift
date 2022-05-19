import Foundation

public extension URLComponents {
    func normalized(options: Normalization) -> URLComponents {
        var result = self
        result.normalize(options: options)
        return result
    }

    var hasAuthority: Bool {
        user?.isEmpty == false || password?.isEmpty == false || host?.isEmpty == false || port != nil
    }
}

public extension URLComponents {
    struct Normalization: OptionSet {
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// Normalizations that preserve semantics:
        
        /// Converting percent-encoded triplets to uppercase.
        /// Decoding percent-encoded triplets of unreserved characters.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let percentEncodings = Self(rawValue: 1 << 0)
        
        /// Converting the scheme and host to lowercase.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let lowercaseSchemeAndHost = Self(rawValue: 1 << 1)
        
        /// Removing dot-segments.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let removeDotSegments = Self(rawValue: 1 << 2)
        
        /// Converting an empty path to a "/" path.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let convertEmptyPath = Self(rawValue: 1 << 3)
        
        /// Removing the default port.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let removeDefaultPort = Self(rawValue: 1 << 4)
        
        
        /// Normalizations that usually preserve semantics:
        
        /// Adding a trailing "/" to a non-empty path.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let addTrailingSlash = Self(rawValue: 1 << 5)
        
        
        /// Normalizations that change semantics:
        
        /// Removing the fragment.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let removeFragment = Self(rawValue: 1 << 6)
        
        /// Removing duplicate slashes.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let removeDuplicateSlashes = Self(rawValue: 1 << 7)
        
        /// Sorting the query parameters.
        /// Not guaranteed to be stable!
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let sortQueryParameters = Self(rawValue: 1 << 8)
        
        /// Removing the "?" when the query is empty.
        /// From https://en.wikipedia.org/wiki/URI_normalization
        static let removeEmptyQuery = Self(rawValue: 1 << 9)
        

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
        
        /// Normalize protocol
        /// From https://github.com/sindresorhus/normalize-url
        static let normalizeProtocol = Self(rawValue: 1 << 17)
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
        
        if options.contains(.lowercaseSchemeAndHost) {
            scheme = scheme?.lowercased()
            host = host?.lowercased()
        }
        
        if options.contains(.removeDotSegments) {
            if !path.isEmpty, let url = url, let cmps = URLComponents(url: url.standardized, resolvingAgainstBaseURL: false) {
                self = cmps
            }
        }
        
        if options.contains(.convertEmptyPath) {
            if hasAuthority && path == "" {
                path = "/"
            }
        }
        
        if options.contains(.removeDefaultPort) {
            if scheme == "http" || scheme == "https", port == 80 {
                port = nil
            }
        }
        
        if options.contains(.addTrailingSlash) {
            if path.last != "/" {
                path += "/"
            }
        }
        
        if options.contains(.removeFragment) {
            fragment = nil
        }
        
        if options.contains(.removeDuplicateSlashes) {
            if path != "/" {
                path = (path as NSString)
                    .pathComponents
                    .map { $0 == "/" ? "" : $0 }
                    .joined(separator: "/")
            }
        }
        
        if options.contains(.sortQueryParameters) {
            queryItems = queryItems.map {
                $0.sorted { $0.name < $1.name }
            }
        }
        
        if options.contains(.removeEmptyQuery) {
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
        
        if options.contains(.normalizeProtocol) {
            if scheme == nil {
                scheme = "http"
            }
        }
    }
}
