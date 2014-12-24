//
//  Diskcached.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 2014/12/21.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

extension String {

    func escape() -> String {

        var str = CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault,
            self,
            nil,
            "!*'\"();:@&=+$,/?%#[]% ",
            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
        return str

    }
}

class Diskcached: NSObject {

    private var images: Dictionary<NSURL, UIImage>  = [NSURL: UIImage]()

    override init() {
        super.init()
        self.createDirectory()
    }

    private func createDirectory() {

        let fileManager: NSFileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(self.directoryPath) {
            return
        }

        fileManager.createDirectoryAtPath(self.directoryPath, withIntermediateDirectories: true, attributes: nil, error: nil)
    }

    private let _queue = dispatch_queue_create("swift.imageloader.queues.diskcached", DISPATCH_QUEUE_SERIAL)

    private var directoryPath: String {
        get {
            let cachePath: String = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as String
            let imagePath: String = "swift.imageloader.diskcached"
            return cachePath.stringByAppendingPathComponent(imagePath)
        }
    }

    private func savePath(name: String ) -> String {
        return self.directoryPath.stringByAppendingPathComponent(name.escape())
    }

    private func objectForKey(aKey: NSURL) -> UIImage? {

        if let image: UIImage = self.images[aKey] {
            return image
        }

        if let data: NSData = NSData(contentsOfFile: self.savePath(aKey.absoluteString!)) {
            return UIImage(data: data)
        }

        return nil
    }

    private func setObject(anObject: UIImage, forKey aKey: NSURL) {

        self.images[aKey] = anObject

        let block: () -> Void = {

            let data: NSData = UIImageJPEGRepresentation(anObject, 1)
            data.writeToFile(self.savePath(aKey.absoluteString!), atomically: false)

            self.images[aKey] = nil
        }

        dispatch_async(_queue, block)
    }

}

extension Diskcached: ImageLoaderCacheProtocol {

    private var _concurrent_queue: dispatch_queue_t {
        get {
            return dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
        }
    }

    subscript (aKey: NSURL) -> UIImage? {

        get {
            var value : UIImage?
            dispatch_sync(_concurrent_queue) {
                value = self.objectForKey(aKey)
            }

            return value
        }

        set {
            dispatch_barrier_async(_concurrent_queue) {
                self.setObject(newValue!, forKey: aKey)
            }
        }
    }

}
