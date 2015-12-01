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

class Diskcached {

    var storedData = [NSURL: NSData]()

    class Directory {
        init() {
            createDirectory()
        }

        private func createDirectory() {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(path) {
                return
            }

            do {
                try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }

        var path: String {
            let cacheDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
            let directoryName = "swift.imageloader.diskcached"

            return cacheDirectory + "/" + directoryName
        }
    }
    let directory = Directory()

    private let _set_queue = dispatch_queue_create("swift.imageloader.queues.diskcached.set", DISPATCH_QUEUE_SERIAL)
    private let _subscript_queue = dispatch_queue_create("swift.imageloader.queues.diskcached.subscript", DISPATCH_QUEUE_CONCURRENT)
}

// MARK: accessor

extension Diskcached {

    private func objectForKey(aKey: NSURL) -> NSData? {
        if let data = storedData[aKey] {
            return data
        }

        return NSData(contentsOfFile: _path(aKey.absoluteString))
    }

    private func _path(name: String) -> String {
        return directory.path + "/" + name.escape()
    }

    private func setObject(anObject: NSData, forKey aKey: NSURL) {

        storedData[aKey] = anObject

        let block: () -> Void = {
            anObject.writeToFile(self._path(aKey.absoluteString), atomically: false)
            self.storedData[aKey] = nil
        }

        dispatch_async(_set_queue, block)
    }
}

// MARK: ImageLoaderCacheProtocol

extension Diskcached: ImageLoaderCache {

    subscript (aKey: NSURL) -> NSData? {

        get {
            return self.objectForKey(aKey)
        }

        set {
            dispatch_barrier_async(_subscript_queue) {
                self.setObject(newValue!, forKey: aKey)
            }
        }
    }
}
