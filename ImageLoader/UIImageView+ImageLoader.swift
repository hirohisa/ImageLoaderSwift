//
//  UIImageView+ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 10/17/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
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
            return objc_getAssociatedObject(self, &ImageLoaderURLKey) as? NSURL
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ImageLoaderURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var block: Block? {
        get {
            return objc_getAssociatedObject(self, &ImageLoaderBlockKey) as? Block
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ImageLoaderBlockKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: - public
    public func load(URL: URLLiteralConvertible, placeholder: UIImage? = nil, completionHandler:CompletionHandler? = nil) {
        cancelLoading()

        if let placeholder = placeholder {
            image = placeholder
        }

        self.URL = URL.imageLoaderURL
        _load(URL.imageLoaderURL, completionHandler: completionHandler)
    }

    public func cancelLoading() {
        if let URL = URL {
            imageLoader.cancel(URL, block: block)
        }
    }

    // MARK: - private
    private static let _Queue = dispatch_queue_create("swift.imageloader.queues.request", DISPATCH_QUEUE_SERIAL)

    private func _load(URL: NSURL, completionHandler: CompletionHandler?) {

        let closure: CompletionHandler = { URL, image, error, cacheType in
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                if let wSelf = self, thisURL = wSelf.URL, image = image where thisURL.isEqual(URL) {
                    wSelf.imageLoader_setImage(image)
                }
            }
            completionHandler?(URL, image, error, cacheType)
        }

        // caching
        if let image = imageLoader.cache[URL] {
            closure(URL, image, nil, .Cache)
            return
        }

        dispatch_async(UIImageView._Queue) { [weak self] in
            guard let wSelf = self else {
                return
            }

            let block = Block(completionHandler: closure)
            let loader = wSelf.imageLoader.load(URL)
                loader.appendBlock(block)
            wSelf.block = block
        }
    }

    private func imageLoader_setImage(image: UIImage) {
        if imageLoader.automaticallyAdjustsSize {
            self.image = image.adjusts(frame.size, scale: UIScreen.mainScreen().scale, contentMode: contentMode)
        } else {
            self.image = image
        }
    }

}