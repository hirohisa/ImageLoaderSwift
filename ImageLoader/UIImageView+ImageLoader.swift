//
//  UIImageView+ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 10/17/14.
//  Copyright © 2014 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

private var ImageLoaderURLKey = 0
private var ImageLoaderBlockKey = 0

/**
 Extension using ImageLoader sends a request, receives image and displays.
 */
extension UIImageView {

    public static var imageLoader = Manager()
    var imageLoader: Manager {
        return UIImageView.imageLoader
    }

    // MARK: - properties

    private var URL: NSURL? {
        get {
            var URL: NSURL?
            dispatch_sync(UIImageView._ioQueue) {
                URL = objc_getAssociatedObject(self, &ImageLoaderURLKey) as? NSURL
            }

            return URL
        }
        set(newValue) {
            dispatch_barrier_async(UIImageView._ioQueue) {
                objc_setAssociatedObject(self, &ImageLoaderURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    // MARK: - public
    public func load(URL: URLLiteralConvertible, placeholder: UIImage? = nil, completionHandler:CompletionHandler? = nil) {
        dispatch_async(UIImageView._Queue) { [weak self] in
            guard let wSelf = self else { return }

            wSelf.cancelLoading()
        }

        if let placeholder = placeholder {
            image = placeholder
        }

        _load(URL.imageLoaderURL, completionHandler: completionHandler)
    }

    public func cancelLoading() {
        if let URL = URL {
            imageLoader.cancel(URL, identifier: hash)
        }
    }

    // MARK: - private
    private static let _ioQueue = dispatch_queue_create("swift.imageloader.queues.io", DISPATCH_QUEUE_CONCURRENT)
    private static let _Queue = dispatch_queue_create("swift.imageloader.queues.request", DISPATCH_QUEUE_SERIAL)

    private func _load(URL: NSURL, completionHandler: CompletionHandler?) {
        let closure: CompletionHandler = { [weak self] URL, image, error, cacheType in
            if let wSelf = self, thisURL = wSelf.URL, image = image where thisURL.isEqual(URL) {
                wSelf.imageLoader_setImage(image)
            }
            completionHandler?(URL, image, error, cacheType)
        }

        // caching
        if let data = imageLoader.cache[URL] {
            self.URL = URL
            closure(URL, UIImage.decode(data), nil, .Cache)
            return
        }

        let identifier = hash
        dispatch_async(UIImageView._Queue) { [weak self] in
            guard let wSelf = self else { return }

            let block = Block(identifier: identifier, completionHandler: closure)
            wSelf.imageLoader.load(URL).appendBlock(block)

            wSelf.URL = URL
        }
    }

    private func imageLoader_setImage(image: UIImage) {
        let size = frame.size
        let mode = contentMode

        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            guard let wSelf = self else { return }

            if wSelf.imageLoader.automaticallyAdjustsSize {
                wSelf.image = image.adjusts(size, scale: UIScreen.mainScreen().scale, contentMode: mode)
            } else {
                wSelf.image = image
            }
        }
    }
    
}