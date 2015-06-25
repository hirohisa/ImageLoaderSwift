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
        if let string = stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            return NSURL(string: string)!
        }
        return NSURL(string: self)!
    }
}

// MARK: Optimize image

extension CGBitmapInfo {
    private var alphaInfo: CGImageAlphaInfo? {
        let info = self & .AlphaInfoMask
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

        var bitmapInfo = CGImageGetBitmapInfo(CGImage)
        var alphaInfo = CGImageGetAlphaInfo(CGImage)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorSpaceModel = CGColorSpaceGetModel(colorSpace)

        switch (colorSpaceModel.value) {
        case kCGColorSpaceModelRGB.value:

            // Reference: http://stackoverflow.com/questions/23723564/which-cgimagealphainfo-should-we-use
            var info = CGImageAlphaInfo.PremultipliedFirst
            switch alphaInfo {
            case .None:
                info = CGImageAlphaInfo.NoneSkipFirst
            default:
                break
            }
            bitmapInfo &= ~CGBitmapInfo.AlphaInfoMask
            bitmapInfo |= CGBitmapInfo(info.rawValue)
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
            bitmapInfo
        )

        let frame = CGRect(x: 0, y: 0, width: Int(width), height: Int(height))

        CGContextDrawImage(context, frame, CGImage)
        let inflatedImageRef = CGBitmapContextCreateImage(context)

        if let inflatedImage = UIImage(CGImage: inflatedImageRef, scale: scale, orientation: imageOrientation) {
            return inflatedImage
        }

        return self
    }
}

// MARK: Cache

/**
    Cache for `ImageLoader` have to implement methods.
    fetch image by cache before sending a request and set image into cache after receiving image data.
*/
public protocol ImageCache: NSObjectProtocol {

    subscript (aKey: NSURL) -> UIImage? {
        get
        set
    }

}

internal typealias CompletionHandler = (NSURL, UIImage?, NSError?) -> ()

internal class Block: NSObject {

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
    Responsible for creating and managing `Loader` objects and controlling of `NSURLSession` and `ImageCache`
*/
public class Manager {

    let session: NSURLSession
    let cache: ImageCache
    let delegate: SessionDataDelegate = SessionDataDelegate()
    public var inflatesImage: Bool = true

    // MARK: singleton instance
    public class var sharedInstance: Manager {
        struct Singleton {
            static let instance = Manager()
        }

        return Singleton.instance
    }

    init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(),
        cache: ImageCache = Diskcached()
        ) {
            session = NSURLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
            self.cache = cache
    }

    // MARK: state

    var state: State {

        var status: State = .Ready

        for loader: Loader in delegate.loaders.values {
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

    internal func load(URL: URLLiteralConvertible) -> Loader {
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

    internal func suspend(URL: URLLiteralConvertible) -> Loader? {
        let URL = URL.URL

        if let loader = delegate[URL] {
            loader.suspend()
            return loader
        }

        return nil
    }

    internal func cancel(URL: URLLiteralConvertible, block: Block? = nil) -> Loader? {
        let URL = URL.URL

        if let loader = delegate[URL] {

            if let block = block {
                loader.remove(block)
            }

            if loader.blocks.count == 0 || block == nil {
                loader.cancel()
                delegate.remove(URL)
            }

            return loader
        }

        return nil
    }

    class SessionDataDelegate: NSObject, NSURLSessionDataDelegate {

        private let _queue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
        private var loaders: [NSURL: Loader]  = [NSURL: Loader]()

        subscript (URL: NSURL) -> Loader? {

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

        private func remove(URL: NSURL) -> Loader? {

            if let loader = self[URL] {
                loaders.removeValueForKey(URL)
                return loader
            }

            return nil
        }

        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
            // TODO: status code 3xx
            if let URL = dataTask.originalRequest.URL, let loader = self[URL] {
                loader.receive(data)
            }
        }

        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
            completionHandler(.Allow)
        }

        func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
            // TODO: status code 3xx
            // loader completion, and store remove loader
            if let URL = task.originalRequest.URL, let loader = self[URL] {
                loader.complete(error)
            }
        }
    }
}

/**
    Responsible for sending a request and receiving the response and calling blocks for the request.
*/
public class Loader {

    let delegate: Manager
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

    public func completionHandler(completionHandler: (NSURL, UIImage?, NSError?) -> ()) -> Self {

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
        var newBlocks: [Block] = []
        for b: Block in blocks {
            if !b.isEqual(block) {
                newBlocks.append(b)
            }
        }

        blocks = newBlocks
    }

    private func receive(data: NSData) {
        receivedData.appendData(data)
    }

    private func complete(error: NSError?) {

        var image: UIImage?
        if let URL = task.originalRequest.URL {

            if error == nil {
                image = UIImage(data: receivedData)
                _toCache(URL, image: image)
            }

            for block: Block in blocks {
                block.completionHandler(URL, image, error)
            }
            blocks = []
        }
    }

    private func _toCache(URL: NSURL, image _image: UIImage?) {
        var image = _image
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
