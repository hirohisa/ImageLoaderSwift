//
//  Diskcached.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/21/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

extension String {

    func escape() -> String {

        let str = CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault,
            self,
            nil,
            "!*'\"();:@&=+$,/?%#[]% ",
            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))

        return str as String
    }
}

class Diskcached: NSObject {

    private var images = [NSURL: UIImage]()

    class Directory {
        init() {
            createDirectory()
        }

        private func createDirectory() {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(path) {
                return
            }

            fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
        }

        var path: String {
            let cacheDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String
            let directoryName = "swift.imageloader.diskcached"

            return cacheDirectory.stringByAppendingPathComponent(directoryName)
        }
    }
    let directory = Directory()

    private let _set_queue = dispatch_queue_create("swift.imageloader.queues.diskcached.set", DISPATCH_QUEUE_SERIAL)
    private let _subscript_queue = dispatch_queue_create("swift.imageloader.queues.diskcached.subscript", DISPATCH_QUEUE_CONCURRENT)
}

// MARK: accessor

extension Diskcached {

    private func objectForKey(aKey: NSURL) -> UIImage? {

        if let image = images[aKey] {
            return image
        }

        if let data = NSData(contentsOfFile: savePath(aKey.absoluteString!)) {
            return UIImage(data: data)
        }

        return nil
    }

    private func savePath(name: String ) -> String {
        return directory.path.stringByAppendingPathComponent(name.escape())
    }

    private func setObject(anObject: UIImage, forKey aKey: NSURL) {

        images[aKey] = anObject

        let block: () -> () = {

            if let data = UIImageJPEGRepresentation(anObject, 1) {
                data.writeToFile(self.savePath(aKey.absoluteString!), atomically: false)
            }

            self.images[aKey] = nil
        }

        dispatch_async(_set_queue, block)
    }
}

// MARK: ImageLoaderCacheProtocol

extension Diskcached: ImageCache {

    subscript (aKey: NSURL) -> UIImage? {

        get {
            var value : UIImage?
            dispatch_sync(_subscript_queue) {
                value = self.objectForKey(aKey)
            }

            return value
        }

        set {
            dispatch_barrier_async(_subscript_queue) {
                self.setObject(newValue!, forKey: aKey)
            }
        }
    }
}
