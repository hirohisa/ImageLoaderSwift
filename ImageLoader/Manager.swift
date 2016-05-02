//
//  Manager.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/7/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

/**
 Responsible for creating and managing `Loader` objects and controlling of `NSURLSession` and `ImageCache`
 */
public class Manager {

    let session: NSURLSession
    let cache: ImageLoaderCache
    let delegate: SessionDataDelegate = SessionDataDelegate()
    public var automaticallyAdjustsSize = true
    public var automaticallyAddTransition = true
    public var automaticallySetImage = true

    /**
     Use to kill or keep a fetching image loader when it's blocks is to empty by imageview or anyone.
     */
    public var shouldKeepLoader = false

    let decompressingQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)

    public init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(),
        cache: ImageLoaderCache = Disk()
        ) {
            session = NSURLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
            self.cache = cache
    }

    // MARK: state

    var state: State {
        return delegate.isEmpty ? .Ready : .Running
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
        return cancel(URL, identifier: block?.identifier)
    }

    func cancel(URL: URLLiteralConvertible, identifier: Int?) -> Loader? {
        if let loader = delegate[URL.imageLoaderURL] {
            if let identifier = identifier {
                loader.remove(identifier)
            }

            if !shouldKeepLoader && loader.blocks.isEmpty {
                loader.cancel()
                delegate.remove(URL.imageLoaderURL)
            }
            return loader
        }

        return nil
    }

    class SessionDataDelegate: NSObject, NSURLSessionDataDelegate {

        let _ioQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
        var loaders: [NSURL: Loader] = [:]

        subscript (URL: NSURL) -> Loader? {
            get {
                var loader : Loader?
                dispatch_sync(_ioQueue) {
                    loader = self.loaders[URL]
                }
                return loader
            }
            set {
                if let newValue = newValue {
                    dispatch_barrier_async(_ioQueue) {
                        self.loaders[URL] = newValue
                    }
                }
            }
        }

        var isEmpty: Bool {
            var isEmpty = false
            dispatch_sync(_ioQueue) {
                isEmpty = self.loaders.isEmpty
            }

            return isEmpty
        }

        private func remove(URL: NSURL) -> Loader? {
            if let loader = loaders[URL] {
                loaders[URL] = nil
                return loader
            }
            return nil
        }

        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
            if let URL = dataTask.originalRequest?.URL, loader = self[URL] {
                loader.receive(data)
            }
        }

        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
            completionHandler(.Allow)
        }

        func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
            if let URL = task.originalRequest?.URL, loader = loaders[URL] {
                loader.complete(error) { [unowned self] in
                    self.remove(URL)
                }
            }
        }

        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, willCacheResponse proposedResponse: NSCachedURLResponse, completionHandler: (NSCachedURLResponse?) -> Void) {
            completionHandler(nil)
        }
    }

    deinit {
        session.invalidateAndCancel()
    }
}