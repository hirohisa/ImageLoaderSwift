//
//  ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 2014/10/16.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

public let ImageLoaderDomain = "swift.imageloader"

public class Manager {

    let session: NSURLSession
    let cache: ImageLoaderCacheProtocol

    // MARK: singleton instance
    public class var sharedInstance: Manager {
        struct Singleton {

            static let instance = Manager()
        }

        return Singleton.instance
    }

    init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(),
        cache: ImageLoaderCacheProtocol = ImageLoaderCache()
        ) {
            self.session = NSURLSession(configuration: configuration)
            self.cache = cache
    }

    // MARK: temporary class
    class LoaderStore: NSObject {

        private let _queue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
        private var loaders: Dictionary<NSURL, Loader>  = [NSURL: Loader]()

        private subscript (URL: NSURL) -> Loader? {

            get {
                var loader : Loader?
                dispatch_sync(_queue) {
                    loader = self.loaders[URL]
                }

                return loader
            }

            set {
                dispatch_barrier_async(_queue) {
                    self.loaders[URL] = newValue!
                }
            }
        }

    }
    let store: LoaderStore = LoaderStore()

    // MARK: loading

    internal func load(URL: NSURL) -> Loader {

        if let loader: Loader = self.store[URL] {

            switch loader.status {

            case .Suspended:
                loader.task.resume()
                return loader

            default:
                return loader
            }

        }

        let request: NSURLRequest = NSURLRequest(URL: URL)
        let task: NSURLSessionDataTask = self.session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            self.taskCompletion(URL, data: data, error: error)
        })

        let loader: Loader = Loader(task: task, delegate: self)
        self.store[URL] = loader
        return loader
    }

    private func taskCompletion(URL: NSURL, data: NSData?, error: NSError?) {

        var image: UIImage?
        if data != nil {
            image = UIImage(data: data!)
            if image != nil {
                self.cache[URL] = image
            }
        }

        if let loader: Loader = self.store[URL] {
            loader.complete(URL, image: image, error: error)
        }

    }

}

public typealias CompletionBlock = (NSURL, UIImage?, NSError?) -> (Void)

public class Loader {

    let delegate: Manager
    let task: NSURLSessionDataTask
    var closures: [CompletionBlock] = [CompletionBlock]()

    // TODO: needs to creating task for class and singleton

    init (task: NSURLSessionDataTask, delegate: Manager) {
        self.task = task
        self.delegate = delegate
        self._run()
    }

    var status: NSURLSessionTaskState {
        get {
            return self.task.state
        }
    }

    internal func completionHandler( completionHandler: (NSURL, UIImage?, NSError?) -> Void ) -> Self {

        self.closures += [completionHandler]

        return self
    }

    private func _run() {
        self.task.resume()
    }

    private func complete(URL: NSURL, image: UIImage?, error: NSError?) {

        for closure: CompletionBlock in self.closures {
            closure(URL, image, error)
        }

    }
}

public func load (URL: NSURL?) -> Loader? {
    if (URL != nil) {
        return Manager.sharedInstance.load(URL!)
    }
    return nil
}
