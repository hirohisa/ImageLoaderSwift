//
//  UIImageView+ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 2014/10/17.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

var ImageLoaderURLKey: UInt = 0

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

    class var sharedImageLoader: ImageLoader {
        struct Static {
            static let imageLoader = ImageLoader()
        }

        return Static.imageLoader
    }

    // MARK: - public

    public func setImage(URL: NSURL, placeholder: UIImage?, completion:(NSURLResponse?, UIImage?, NSError?) -> Void) {

        self._setImage(URL, placeholder: placeholder, success: { (response, image) -> Void in

            completion(response, image, nil)

        }, failure: { (response, error) -> Void in

            completion(response, nil, error)

        })

    }

    public func setImage(URL: NSURL, placeholder: UIImage? = nil, success:(NSURLResponse?, UIImage) -> Void = { _ in }, failure:(NSURLResponse?, NSError) -> Void = { _ in }) {

        self._setImage(URL, placeholder: placeholder, success: success, failure: failure)

    }

    public func cancelLoadingImage() {

        if self.URL != nil {
            UIImageView.sharedImageLoader.cancel(self.URL!)
        }

    }

    // MARK: - private

    private class var requesting_queue: dispatch_queue_t {
        struct Static {
            static let queue = dispatch_queue_create("swift.imageloader.queues.requesting", DISPATCH_QUEUE_SERIAL);
        }

        return Static.queue
    }

    private func _setImage(URL: NSURL, placeholder: UIImage?, success:(NSURLResponse?, UIImage) -> Void, failure:(NSURLResponse?, NSError) -> Void) {

        let successHandler: (NSURLResponse?, UIImage) -> Void = { (response, image) in

            if self.URL != nil && response != nil && self.URL!.isEqual(response!.URL) {

                weak var wSelf = self
                dispatch_async(dispatch_get_main_queue(), { _ in
                    if wSelf == nil {
                        return
                    }

                    wSelf!.image = image
                })

            }

            success(response, image)

        }

        let failureHandler: (NSURLResponse?, NSError) -> Void = { (response, error) in

            failure(response, error)

        }

        // cache check

        if let data: NSData = UIImageView.sharedImageLoader.cache.objectForKey(URL) as? NSData {

            if let image: UIImage = UIImage(data: data) {
                success(nil, image)
                return
            }

        }

        self.cancelLoadingImage()

        if placeholder != nil {
            self.image = placeholder
        }

        self.URL = URL

        dispatch_async(UIImageView.requesting_queue, { _ in

            UIImageView.sharedImageLoader.getImage(URL, success:successHandler, failure:failureHandler)
            return

        })

    }

}