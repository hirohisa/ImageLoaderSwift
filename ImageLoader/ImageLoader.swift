//
//  ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 2014/10/16.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

let ImageLoaderDomain = "swift.imageloader"

class ImageLoader: NSObject {

    let session: NSURLSession
    var keepRequest: Bool
    let cache: ImageLoaderCacheProtocol

    var tasks: [NSURLSessionDataTask] {
        get {
            var _tasks: [NSURLSessionDataTask]?
            var semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)

            self.session.getTasksWithCompletionHandler({ (dataTasks, _, _) -> Void in
                _tasks = dataTasks as? [NSURLSessionDataTask]
                dispatch_semaphore_signal(semaphore)
            })

            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

            return _tasks!
        }
    }

    init( config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(),
        cache: ImageLoaderCacheProtocol = ImageLoaderCache()) {

            self.keepRequest = false
            self.session = NSURLSession(configuration: config)
            self.cache = cache

    }

    // MARK: - public

    internal func getImage( URL: NSURL,
        success: (NSURLResponse?, UIImage) -> Void = { _ in },
        failure: (NSURLResponse?, NSError) -> Void = { _ in }) -> NSURLSessionDataTask? {

            return self._getImage(URL, success: success, failure: failure)

    }

    internal func cancel( URL: NSURL ) {

        for task: NSURLSessionDataTask in self.tasks {

            if task.originalRequest.URL.isEqual(URL) {
                task.cancel()
            }

        }

    }

    // MARK: - private

    private func _getImage(URL: NSURL, success: (NSURLResponse?, UIImage) -> Void, failure: (NSURLResponse?, NSError) -> Void) -> NSURLSessionDataTask? {

        let completionHandler: (NSData!, NSURLResponse!, NSError!) -> Void = { (data, response, error) in

            if error == nil {

                if let image: UIImage = UIImage(data: data) {

                    self.cache.setObject(data, forKey: URL)
                    success(response, image)

                } else {

                    let errorNotImage: NSError = NSError(domain: ImageLoaderDomain, code: 204 /* no content */, userInfo: nil)
                    failure(response, errorNotImage)
                }

            } else {
                failure(response?, error)
            }

        }

        // cache check

        if let data: NSData = self.cache.objectForKey(URL) as? NSData {

            if let image: UIImage = UIImage(data: data) {
                success(nil, image)
            }

        }

        return self._enqueueTask(URL, completionHandler: completionHandler)
    }

    private func _enqueueTask(URL: NSURL, completionHandler: (NSData!, NSURLResponse!, NSError!) -> Void) -> NSURLSessionDataTask? {

        let request: NSMutableURLRequest = NSMutableURLRequest(URL: URL)
        request.addValue("image/*", forHTTPHeaderField:"Accept")

        let task: NSURLSessionDataTask = self._createTask(request, completionHandler: completionHandler)
        task.resume()

        return task
    }

    // MARK: - creating task

    private class var creation_queue: dispatch_queue_t {
        struct Static {
            static let queue = dispatch_queue_create("swift.imageloader.queues.creation", DISPATCH_QUEUE_SERIAL);
        }

        return Static.queue
    }

    private func _createTask(request: NSURLRequest, completionHandler: (NSData!, NSURLResponse!, NSError!) -> Void) -> NSURLSessionDataTask {

        var task: NSURLSessionDataTask?
        dispatch_sync(ImageLoader.creation_queue, { _ in
            task = self.session.dataTaskWithRequest(request, completionHandler: completionHandler)
        })

        return task!
    }

}