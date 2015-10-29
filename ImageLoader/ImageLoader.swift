//
//  ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 10/16/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
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
    fetch image by cache before sending a request and set image into cache after receiving image data.
*/
public protocol ImageCache: class {

    subscript (aKey: NSURL) -> UIImage? {
        get
        set
    }

}

public typealias CompletionHandler = (NSURL, UIImage?, NSError?, CacheType) -> Void

class Block: NSObject {

    let completionHandler: CompletionHandler
    init(completionHandler: CompletionHandler) {
        self.completionHandler = completionHandler
    }

}

/**
    Use to check state of loaders that manager has.
    Ready:      The manager have no loaders
    Running:    The manager has loaders, and they are running
    Suspended:  The manager has loaders, and their states are all suspended
*/
public enum State {
    case Ready
    case Running
    case Suspended
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

/**
    Responsible for creating and managing `Loader` objects and controlling of `NSURLSession` and `ImageCache`
*/
public class Manager {

    let session: NSURLSession
    let cache: ImageCache
    let delegate: SessionDataDelegate = SessionDataDelegate()
    public var automaticallyAdjustsSize = true

    /**
        Use to kill or keep a fetching image loader when it's blocks is to empty by imageview or anyone.
    */
    public var shouldKeepLoader = false

    private let decompressingQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)

    init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(),
        cache: ImageCache = Diskcached()
        ) {
            session = NSURLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
            self.cache = cache
    }

    // MARK: state

    var state: State {

        var status = State.Ready
        for loader in delegate.loaders.values {
            switch loader.state {
            case .Running:
                status = .Running
            case .Suspended:
                if status == .Ready {
                    status = .Suspended
                }
            default:
                break
            }
        }
        return status
    }

    // MARK: loading

    func load(URL: URLLiteralConvertible) -> Loader {
        if let loader = delegate[URL.imageLoaderURL] {
            loader.resume()
            return loader
        }

        let request = NSMutableURLRequest(URL: URL.imageLoaderURL)
        request.setValue("image/*", forHTTPHeaderField: "Accept")
        let task = session.dataTaskWithRequest(request)

        let loader = Loader(task: task, delegate: self)
        delegate[URL.imageLoaderURL] = loader
        return loader
    }

    func suspend(URL: URLLiteralConvertible) -> Loader? {
        if let loader = delegate[URL.imageLoaderURL] {
            loader.suspend()
            return loader
        }

        return nil
    }

    func cancel(URL: URLLiteralConvertible, block: Block? = nil) -> Loader? {
        if let loader = delegate[URL.imageLoaderURL] {
            if let block = block {
                loader.remove(block)
            }

            if !shouldKeepLoader && loader.blocks.count == 0 {
                loader.cancel()
                delegate.remove(URL.imageLoaderURL)
            }
            return loader
        }

        return nil
    }

    class SessionDataDelegate: NSObject, NSURLSessionDataDelegate {

        private let _queue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
        private var loaders = [NSURL: Loader]()

        subscript (URL: NSURL) -> Loader? {
            get {
                var loader : Loader?
                dispatch_sync(_queue) {
                    loader = self.loaders[URL]
                }
                return loader
            }
            set {
                if let newValue = newValue {
                    dispatch_barrier_async(_queue) {
                        self.loaders[URL] = newValue
                    }
                }
            }
        }

        private func remove(URL: NSURL) -> Loader? {
            if let loader = self[URL] {
                loaders[URL] = nil
                return loader
            }
            return nil
        }

        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
            if let URL = dataTask.originalRequest?.URL, let loader = self[URL] {
                loader.receive(data)
            }
        }

        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
            completionHandler(.Allow)
        }

        func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
            if let URL = task.originalRequest?.URL, let loader = self[URL] {
                loader.complete(error)
                remove(URL)
            }
        }
    }
}

/**
    Responsible for sending a request and receiving the response and calling blocks for the request.
*/
public class Loader {

    unowned let delegate: Manager
    let task: NSURLSessionDataTask
    var receivedData = NSMutableData()
    internal var blocks: [Block] = []

    init (task: NSURLSessionDataTask, delegate: Manager) {
        self.task = task
        self.delegate = delegate
        resume()
    }

    var state: NSURLSessionTaskState {
        return task.state
    }

    public func completionHandler(completionHandler: CompletionHandler) -> Self {
        let block = Block(completionHandler: completionHandler)
        return appendBlock(block)
    }

    func appendBlock(block: Block) -> Self {
        blocks.append(block)
        return self
    }

    // MARK: task

    public func suspend() {
        task.suspend()
    }

    public func resume() {
        task.resume()
    }

    public func cancel() {
        task.cancel()
    }

    private func remove(block: Block) {
        // needs to queue with sync
        blocks = blocks.filter{ !$0.isEqual(block) }
    }

    private func receive(data: NSData) {
        receivedData.appendData(data)
    }

    private func complete(error: NSError?) {

        if let URL = task.originalRequest?.URL {
            if let error = error {
                failure(URL, error: error)
                return
            }
            dispatch_async(delegate.decompressingQueue) {
                self.success(URL, data: self.receivedData)
            }
        }
    }

    private func success(URL: NSURL, data: NSData) {
        let image = UIImage.decode(data)
        _toCache(URL, image: image)

        for block: Block in blocks {
            block.completionHandler(URL, image, nil, .None)
        }
        blocks = []
    }

    private func failure(URL: NSURL, error: NSError) {
        for block: Block in blocks {
            block.completionHandler(URL, nil, error, .None)
        }
        blocks = []
    }

    private func _toCache(URL: NSURL, image: UIImage?) {
        if let image = image {
            delegate.cache[URL] = image
        }
    }

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

/**
    Fetches the image using the shared manager instance's `ImageCache` object for the specified URL.
*/
public func cache(URL: URLLiteralConvertible) -> UIImage? {
    return sharedInstance.cache[URL.imageLoaderURL]
}

public var state: State {
    return sharedInstance.state
}
