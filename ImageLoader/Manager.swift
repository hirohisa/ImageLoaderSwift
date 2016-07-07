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

    let session: URLSession
    let cache: ImageLoaderCache
    let delegate: SessionDataDelegate = SessionDataDelegate()
    public var automaticallyAdjustsSize = true
    public var automaticallyAddTransition = true
    public var automaticallySetImage = true

    /**
     Use to kill or keep a fetching image loader when it's blocks is to empty by imageview or anyone.
     */
    public var shouldKeepLoader = false

    let decompressingQueue = DispatchQueue(label: "swift.imageloader.queues.decompress", attributes: DispatchQueueAttributes.concurrent)

    public init(configuration: URLSessionConfiguration = URLSessionConfiguration.default(),
        cache: ImageLoaderCache = Disk()
        ) {
            session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
            self.cache = cache
    }

    // MARK: state

    var state: State {
        return delegate.isEmpty ? .ready : .running
    }

    // MARK: loading

    func load(_ URL: URLLiteralConvertible) -> Loader {
        if let loader = delegate[URL.imageLoaderURL] {
            loader.resume()
            return loader
        }

        let request = NSMutableURLRequest(url: URL.imageLoaderURL)
        request.setValue("image/*", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request.url!)

        let loader = Loader(task: task, delegate: self)
        delegate[URL.imageLoaderURL] = loader
        return loader
    }

    func suspend(_ URL: URLLiteralConvertible) -> Loader? {
        if let loader = delegate[URL.imageLoaderURL] {
            loader.suspend()
            return loader
        }

        return nil
    }

    func cancel(_ URL: URLLiteralConvertible, block: Block? = nil) -> Loader? {
        return cancel(URL, identifier: block?.identifier)
    }

    func cancel(_ URL: URLLiteralConvertible, identifier: Int?) -> Loader? {
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

    class SessionDataDelegate: NSObject, URLSessionDataDelegate {

        let _ioQueue = DispatchQueue(label: "swift.imageloader.queues.session.io", attributes: DispatchQueueAttributes.concurrent)
        var loaders: [URL: Loader] = [:]

        subscript (url: URL) -> Loader? {
            get {
                var loader : Loader?
                _ioQueue.sync {
                    loader = self.loaders[url]
                }
                return loader
            }
            set {
                if let newValue = newValue {
                    _ioQueue.async {
                        self.loaders[url] = newValue
                    }
                }
            }
        }

        var isEmpty: Bool {
            var isEmpty = false
            _ioQueue.sync {
                isEmpty = self.loaders.isEmpty
            }

            return isEmpty
        }

        private func remove(_ url: URL) -> Loader? {
            if let loader = loaders[url] {
                loaders[url] = nil
                return loader
            }
            return nil
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            if let url = dataTask.originalRequest?.url, loader = self[url] {
                loader.receive(data)
            }
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
            completionHandler(.allow)
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
            if let url = task.originalRequest?.url, loader = loaders[url] {
                loader.complete(error) { [unowned self] in
                    self.remove(url)
                }
            }
        }

        private func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: (CachedURLResponse) -> Void) {
            completionHandler(proposedResponse)
        }
    }

    deinit {
        session.invalidateAndCancel()
    }
}
