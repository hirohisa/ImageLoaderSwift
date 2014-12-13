//
//  ImageLoaderCache.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 2014/10/27.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

import Foundation

public protocol ImageLoaderCacheProtocol : NSObjectProtocol {

    subscript (aKey: AnyObject) -> AnyObject? {
        get
        set
    }

}

class ImageLoaderCache: NSCache, ImageLoaderCacheProtocol {

    private let _queue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)

    subscript (aKey: AnyObject) -> AnyObject? {

        get {
            var value : AnyObject?
            dispatch_sync(_queue) {
                value = self.objectForKey(aKey)
            }

            return value
        }

        set {
            dispatch_barrier_async(_queue) {
                self.setObject(newValue!, forKey: aKey)
            }
        }
    }
}