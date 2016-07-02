//
//  Disk.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/21/14.
//  Copyright © 2014 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

extension String {

    public func escape() -> String {

        let str = CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault,
            self,
            nil,
            "!*'\"();:@&=+$,/?%#[]% ",
            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))

        return str as String
    }
}

public class Disk {

    var storedData = [String: NSData]()

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
            let directoryName = "swift.imageloader.disk"

            return cacheDirectory + "/" + directoryName
        }
    }
    let directory = Directory()

    private let _subscriptQueue = dispatch_queue_create("swift.imageloader.queues.disk.subscript", DISPATCH_QUEUE_CONCURRENT)
    private let _ioQueue = dispatch_queue_create("swift.imageloader.queues.disk.set", DISPATCH_QUEUE_SERIAL)
}

extension Disk {

    public class func cleanUp() {
        Disk().cleanUp()
    }

    func cleanUp() {
        let manager = NSFileManager.defaultManager()
        for subpath in manager.subpathsAtPath(directory.path) ?? [] {
            let path = directory.path + "/" + subpath
            do {
                try manager.removeItemAtPath(path)
            } catch _ {
            }
        }
    }

    public class func get(aKey: String) -> NSData? {
        return Disk().get(aKey)
    }

    public class func set(anObject: NSData, forKey aKey: String) {
        Disk().set(anObject, forKey: aKey)
    }

    public func get(aKey: String) -> NSData? {
        if let data = storedData[aKey] {
            return data
        }
        return NSData(contentsOfFile: _path(aKey))
    }

    private func get(aKey: NSURL) -> NSData? {
        return get(aKey.absoluteString!.escape())
    }

    private func _path(name: String) -> String {
        return directory.path + "/" + name
    }

    public func set(anObject: NSData, forKey aKey: String) {
        storedData[aKey] = anObject

        let block: () -> Void = {
            anObject.writeToFile(self._path(aKey), atomically: false)
            self.storedData[aKey] = nil
        }

        dispatch_async(_ioQueue, block)
    }

    private func set(anObject: NSData, forKey aKey: NSURL) {
        set(anObject, forKey: aKey.absoluteString!.escape())
    }
}

extension Disk: ImageLoaderCache {

    public subscript (aKey: NSURL) -> NSData? {
        get {
            var data : NSData?
            dispatch_sync(_subscriptQueue) {
                data = self.get(aKey)
            }
            return data
        }

        set {
            dispatch_barrier_async(_subscriptQueue) {
                self.set(newValue!, forKey: aKey)
            }
        }
    }
}
