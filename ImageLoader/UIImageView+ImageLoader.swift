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

    public static var imageLoader = sharedInstance

    // MARK: - properties
    private static let _ioQueue = dispatch_queue_create("swift.imageloader.queues.io", DISPATCH_QUEUE_CONCURRENT)

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

    private static let _Queue = dispatch_queue_create("swift.imageloader.queues.request", DISPATCH_QUEUE_SERIAL)

    // MARK: - functions
    public func load(URL: URLLiteralConvertible, placeholder: UIImage? = nil, completionHandler:CompletionHandler? = nil) {
        let block: () -> Void = { [weak self] in
            guard let wSelf = self else { return }

            wSelf.cancelLoading()
        }
        enqueue(block)

        image = placeholder

        imageLoader_load(URL.imageLoaderURL, completionHandler: completionHandler)
    }

    public func cancelLoading() {
        if let URL = URL {
            UIImageView.imageLoader.cancel(URL, identifier: hash)
        }
    }

    // MARK: - private

    private func imageLoader_load(URL: NSURL, completionHandler: CompletionHandler?) {
        let handler: CompletionHandler = { [weak self] URL, image, error, cacheType in
            if let wSelf = self, thisURL = wSelf.URL, image = image where thisURL.isEqual(URL) {
                wSelf.imageLoader_setImage(image, cacheType)
            }

            dispatch_main {
                completionHandler?(URL, image, error, cacheType)
            }
        }

        // caching
        if let data = UIImageView.imageLoader.cache[URL] {
            self.URL = URL
            handler(URL, UIImage.decode(data), nil, .Cache)
            return
        }


        let identifier = hash
        let block: () -> Void = { [weak self] in
            guard let wSelf = self else { return }

            let block = Block(identifier: identifier, completionHandler: handler)
            UIImageView.imageLoader.load(URL).appendBlock(block)

            wSelf.URL = URL
        }

        enqueue(block)
    }

    private func enqueue(block: () -> Void) {
        dispatch_async(UIImageView._Queue, block)
    }

    private func imageLoader_setImage(image: UIImage, _ cacheType: CacheType) {
        dispatch_main { [weak self] in
            guard let wSelf = self else { return }
            if !UIImageView.imageLoader.automaticallySetImage { return }

            // Add a transition
            if UIImageView.imageLoader.automaticallyAddTransition && cacheType == CacheType.None {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionFade
                wSelf.layer.addAnimation(transition, forKey: nil)
            }

            // Set an image
            if UIImageView.imageLoader.automaticallyAdjustsSize {
                wSelf.image = image.adjusts(wSelf.frame.size, scale: UIScreen.mainScreen().scale, contentMode: wSelf.contentMode)
            } else {
                wSelf.image = image
            }

        }
    }

}