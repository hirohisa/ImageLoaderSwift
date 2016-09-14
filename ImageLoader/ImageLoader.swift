//
//  ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 10/16/14.
//  Copyright © 2014 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

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

// MARK: Cache

/**
    Cache for `ImageLoader` have to implement methods.
    find data in Cache before sending a request and set data into cache after receiving.
*/
public protocol ImageLoaderCache: class {

    subscript (aKey: URL) -> Data? {
        get
        set
    }

}

public typealias CompletionHandler = (URL, UIImage?, Error?, CacheType) -> Void

class Block {

    let identifier: Int
    let completionHandler: CompletionHandler
    init(identifier: Int, completionHandler: @escaping CompletionHandler) {
        self.identifier = identifier
        self.completionHandler = completionHandler
    }

}

extension Block: Equatable {}

func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.identifier == rhs.identifier
}

/**
    Use to check state of loaders that manager has.
    Ready:      The manager have no loaders
    Running:    The manager has loaders
*/
public enum State {
    case ready
    case running
}

/**
    Use to check where image is loaded from.
    None:   fetching from network
    Cache:  getting from `ImageCache`
*/
public enum CacheType {
    case none
    case cache
}

// MARK: singleton instance
public let sharedInstance = Manager()

/**
    Creates `Loader` object using the shared manager instance for the specified URL.
*/
public func load(_ url: URLLiteralConvertible) -> Loader {
    return sharedInstance.load(url)
}

/**
    Suspends `Loader` object using the shared manager instance for the specified URL.
*/
public func suspend(_ url: URLLiteralConvertible) -> Loader? {
    return sharedInstance.suspend(url)
}

/**
    Cancels `Loader` object using the shared manager instance for the specified URL.
*/
public func cancel(_ url: URLLiteralConvertible) {
    sharedInstance.cancel(url)
}

public var state: State {
    return sharedInstance.state
}

func dispatch_main(_ block: @escaping (Void) -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}
