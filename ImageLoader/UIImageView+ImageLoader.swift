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
}

extension UIImageView {

    // MARK: - public

    public func load(URL: NSURL, placeholder: UIImage?, completionHandler:(NSURL, UIImage?, NSError?) -> Void) {

        self.cancelLoadingImage()
        self._load(URL, placeholder: placeholder, completionHandler: completionHandler)

    }

    public func cancelLoadingImage() {
        if self.URL != nil {
            // TODO: cancel with completion handler
        }
    }

    // MARK: - private

    private class var _requesting_queue: dispatch_queue_t {
        struct Static {
            static let queue = dispatch_queue_create("swift.imageloader.queues.requesting", DISPATCH_QUEUE_SERIAL);
        }

        return Static.queue
    }

    private func _load(URL: NSURL, placeholder: UIImage?, completionHandler:(NSURL, UIImage?, NSError?) -> Void) {

        let completionHandler: (NSURL, UIImage?, NSError?) -> Void = { (URL, image, error) in

            // requesting is success then set image
            if self.URL != nil && self.URL!.isEqual(URL) {

                weak var wSelf = self
                dispatch_async(dispatch_get_main_queue(), { _ in
                    if wSelf == nil {
                        return
                    }

                    wSelf!.image = image
                })

            }

            completionHandler(URL, image, error)
        }

        // caching
        if  let data: NSData = Manager.sharedInstance.cache[URL] as? NSData {
            if let image: UIImage = UIImage(data: data) {
                completionHandler(URL, image, nil)
                return
            }
        }

        if placeholder != nil {
            self.image = placeholder
        }

        self.URL = URL

        dispatch_async(UIImageView._requesting_queue, { _ in

            Manager.sharedInstance.load(URL).completionHandler(completionHandler)
            return

        })

    }

}