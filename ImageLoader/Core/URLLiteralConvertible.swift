//
//  URLLiteralConvertible.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 11/4/16.
//  Copyright © 2016 Hirohisa Kawasaki. All rights reserved.
//

import Foundation

public protocol URLLiteralConvertible {
    var imageLoaderURL: URL { get }
}

extension URL: URLLiteralConvertible {
    public var imageLoaderURL: URL {
        return self
    }
}

extension URLComponents: URLLiteralConvertible {
    public var imageLoaderURL: URL {
        return url!
    }
}

extension String: URLLiteralConvertible {
    public var imageLoaderURL: URL {
        if let string = addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: string)!
        }
        return URL(string: self)!
    }
}
