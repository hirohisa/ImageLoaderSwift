//
//  ImageLoaderCache.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 2014/10/27.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

import Foundation

protocol ImageLoaderCacheProtocol : NSObjectProtocol {

    func objectForKey(aKey: AnyObject) -> AnyObject?
    func setObject(anObject: AnyObject, forKey aKey: AnyObject)

}

class ImageLoaderCache: NSCache, ImageLoaderCacheProtocol {

    override func objectForKey(aKey: AnyObject) -> AnyObject? {

        return super.objectForKey(aKey)

    }

    override func setObject(anObject: AnyObject, forKey aKey: AnyObject) {

        super.setObject(anObject, forKey: aKey)

    }
}