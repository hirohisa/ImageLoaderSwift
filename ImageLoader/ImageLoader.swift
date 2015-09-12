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
    var URL: NSURL { get }
}

extension NSURL: URLLiteralConvertible {
    public var URL: NSURL {
        return self
    }
}

extension String: URLLiteralConvertible {
    public var URL: NSURL {
        if let string = stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) {
            return NSURL(string: string)!
        }
        return NSURL(string: self)!
    }
}

// MARK: Optimize image

extension CGBitmapInfo {
    private var alphaInfo: CGImageAlphaInfo? {
        let info = self.intersect(.AlphaInfoMask)
        return CGImageAlphaInfo(rawValue: info.rawValue)
    }
}

extension UIImage {

    private func inflated() -> UIImage {
        let scale = UIScreen.mainScreen().scale
        let width = CGImageGetWidth(CGImage)
        let height = CGImageGetHeight(CGImage)
        if !(width > 0 && height > 0) {
            return self
        }

        let bitsPerComponent = CGImageGetBitsPerComponent(CGImage)

        if (bitsPerComponent > 8) {
            return self
        }

        var bitmapInfoValue = CGImageGetBitmapInfo(CGImage).rawValue
        let alphaInfo = CGImageGetAlphaInfo(CGImage)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorSpaceModel = CGColorSpaceGetModel(colorSpace)

        switch (colorSpaceModel.rawValue) {
        case CGColorSpaceModel.RGB.rawValue:

            // Reference: http://stackoverflow.com/questions/23723564/which-cgimagealphainfo-should-we-use
            var info = CGImageAlphaInfo.PremultipliedFirst
            switch alphaInfo {
            case .None:
                info = CGImageAlphaInfo.NoneSkipFirst
            default:
                break
            }
            bitmapInfoValue &= ~CGBitmapInfo.AlphaInfoMask.rawValue
            bitmapInfoValue |= info.rawValue
        default:
            break
        }

        let context = CGBitmapContextCreate(
            nil,
            width,
            height,
            bitsPerComponent,
            0,
            colorSpace,
            bitmapInfoValue
        )

        let frame = CGRect(x: 0, y: 0, width: width, height: height)

        CGContextDrawImage(context, frame, CGImage)

        if let cgImage = CGBitmapContextCreateImage(context) {
            return UIImage(CGImage: cgImage, scale: scale, orientation: imageOrientation)
        }

        return self
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

typealias CompletionHandler = (NSURL, UIImage?, NSError?, CacheType) -> ()

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
    public var inflatesImage: Bool = true

    private let decompressingQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)

    // MARK: singleton instance
    public static let sharedInstance = Manager()

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
        let URL = URL.URL
        if let loader = delegate[URL] {
            loader.resume()
            return loader
        }

        let request = NSMutableURLRequest(URL: URL)
        request.setValue("image/*", forHTTPHeaderField: "Accept")
        let task = session.dataTaskWithRequest(request)

        let loader = Loader(task: task, delegate: self)
        delegate[URL] = loader
        return loader
    }

    func suspend(URL: URLLiteralConvertible) -> Loader? {
        if let loader = delegate[URL.URL] {
            loader.suspend()
            return loader
        }

        return nil
    }

    func cancel(URL: URLLiteralConvertible, block: Block? = nil) -> Loader? {
        if let loader = delegate[URL.URL] {
            if let block = block {
                loader.remove(block)
            }

            if loader.blocks.count == 0 || block == nil {
                loader.cancel()
                delegate.remove(URL.URL)
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
                loaders.removeValueForKey(URL)
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
    var receivedData: NSMutableData = NSMutableData()
    let inflatesImage: Bool
    internal var blocks: [Block] = []

    init (task: NSURLSessionDataTask, delegate: Manager) {
        self.task = task
        self.delegate = delegate
        self.inflatesImage = delegate.inflatesImage
        self.resume()
    }

    var state: NSURLSessionTaskState {
        return task.state
    }

    public func completionHandler(completionHandler: (NSURL, UIImage?, NSError?, CacheType) -> ()) -> Self {

        let block = Block(completionHandler: completionHandler)
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
        let image = UIImage(data: data)
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
        var image = image
        if inflatesImage {
            image = image?.inflated()
        }
        if let image = image {
            delegate.cache[URL] = image
        }
    }

}

/**
    Creates `Loader` object using the shared manager instance for the specified URL.
*/
public func load(URL: URLLiteralConvertible) -> Loader {
    return Manager.sharedInstance.load(URL)
}

/**
    Suspends `Loader` object using the shared manager instance for the specified URL.
*/
public func suspend(URL: URLLiteralConvertible) -> Loader? {
    return Manager.sharedInstance.suspend(URL)
}

/**
    Cancels `Loader` object using the shared manager instance for the specified URL.
*/
public func cancel(URL: URLLiteralConvertible) -> Loader? {
    return Manager.sharedInstance.cancel(URL)
}

/**
    Fetches the image using the shared manager instance's `ImageCache` object for the specified URL.
*/
public func cache(URL: URLLiteralConvertible) -> UIImage? {
    let URL = URL.URL

    return Manager.sharedInstance.cache[URL]
}

public var state: State {
    return Manager.sharedInstance.state
}
