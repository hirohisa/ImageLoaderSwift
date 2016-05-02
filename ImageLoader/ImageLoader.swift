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
    var imageLoaderURL: NSURL { get }
}

extension NSURL: URLLiteralConvertible {
    public var imageLoaderURL: NSURL {
        return self
    }
}

extension NSURLComponents: URLLiteralConvertible {
    public var imageLoaderURL: NSURL {
        return URL!
    }
}

extension String: URLLiteralConvertible {
    public var imageLoaderURL: NSURL {
        if let string = stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) {
            return NSURL(string: string)!
        }
        return NSURL(string: self)!
    }
}

// MARK: Cache

/**
    Cache for `ImageLoader` have to implement methods.
    find data in Cache before sending a request and set data into cache after receiving.
*/
public protocol ImageLoaderCache: class {

    subscript (aKey: NSURL) -> NSData? {
        get
        set
    }

}

public typealias CompletionHandler = (NSURL, UIImage?, NSError?, CacheType) -> Void

class Block {

    let identifier: Int
    let completionHandler: CompletionHandler
    init(identifier: Int, completionHandler: CompletionHandler) {
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
    case Ready
    case Running
}

/**
    Use to check where image is loaded from.
    None:   fetching from network
    Cache:  getting from `ImageCache`
*/
public enum CacheType {
    case None
    case Cache
}

// MARK: singleton instance
public let sharedInstance = Manager()

/**
    Creates `Loader` object using the shared manager instance for the specified URL.
*/
public func load(URL: URLLiteralConvertible) -> Loader {
    return sharedInstance.load(URL)
}

/**
    Suspends `Loader` object using the shared manager instance for the specified URL.
*/
public func suspend(URL: URLLiteralConvertible) -> Loader? {
    return sharedInstance.suspend(URL)
}

/**
    Cancels `Loader` object using the shared manager instance for the specified URL.
*/
public func cancel(URL: URLLiteralConvertible) -> Loader? {
    return sharedInstance.cancel(URL)
}

public var state: State {
    return sharedInstance.state
}

func dispatch_main(block: dispatch_block_t) {
    if NSThread.isMainThread() {
        block()
    } else {
        dispatch_async(dispatch_get_main_queue(), block)
    }
}