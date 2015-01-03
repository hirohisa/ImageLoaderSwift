//
//  UIImageView+ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 2014/10/17.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

private var ImageLoaderURLKey: UInt = 0
private var ImageLoaderBlockKey: UInt = 0

extension UIImageView {

    // MARK: - properties

    private var URL: NSURL? {
        get {
            return objc_getAssociatedObject(self, &ImageLoaderURLKey) as? NSURL
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ImageLoaderURLKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }

    private var block: AnyObject? {
        get {
            return objc_getAssociatedObject(self, &ImageLoaderBlockKey)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ImageLoaderBlockKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
}

extension UIImageView {

    // MARK: - public

    public func load(URL: NSURL, placeholder: UIImage?, completionHandler:(NSURL, UIImage?, NSError?) -> ()) {
        self.cancelLoading()

        if let placeholder = placeholder {
            self.image = placeholder
        }

        self.URL = URL
        self._load(URL, completionHandler: completionHandler)
    }

    public func cancelLoading() {
        if let URL = self.URL {
            Manager.sharedInstance.cancel(URL, block: self.block as? Block)
        }
    }

    // MARK: - private

    private class var _requesting_queue: dispatch_queue_t {
        struct Static {
            static let queue = dispatch_queue_create("swift.imageloader.queues.requesting", DISPATCH_QUEUE_SERIAL)
        }

        return Static.queue
    }

    private func _load(URL: NSURL, completionHandler:(NSURL, UIImage?, NSError?) -> ()) {

        weak var wSelf = self
        let completionHandler: (NSURL, UIImage?, NSError?) -> () = { URL, image, error in

            if wSelf == nil {
                return
            }

            dispatch_async(dispatch_get_main_queue(), {

                // requesting is success then set image
                if self.URL != nil && self.URL!.isEqual(URL) {
                    if let image = image {
                        wSelf!.image = image.resized(size: wSelf!.frame.size)
                    }
                }
                completionHandler(URL, image, error)

            })
        }

        // caching
        if let image = Manager.sharedInstance.cache[URL] {
            completionHandler(URL, image, nil)
            return
        }

        dispatch_async(UIImageView._requesting_queue, {

            let loader = Manager.sharedInstance.load(URL).completionHandler(completionHandler)
            self.block = loader.blocks.last

            return

        })

    }

}