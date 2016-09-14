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

    public func escape() -> String? {
        return addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }
}

public class Disk {

    var storedData = [String: Data]()

    class Directory {
        init() {
            createDirectory()
        }

        private func createDirectory() {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path) {
                return
            }

            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }

        var path: String {
            let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let directoryName = "swift.imageloader.disk"

            return cacheDirectory + "/" + directoryName
        }
    }
    let directory = Directory()

    fileprivate let _subscriptQueue = DispatchQueue(label: "swift.imageloader.queues.disk.subscript", attributes: .concurrent)
    fileprivate let _ioQueue = DispatchQueue(label: "swift.imageloader.queues.disk.set")
}

extension Disk {

    public class func cleanUp() {
        Disk().cleanUp()
    }

    func cleanUp() {
        let manager = FileManager.default
        for subpath in manager.subpaths(atPath: directory.path) ?? [] {
            let path = directory.path + "/" + subpath
            do {
                try manager.removeItem(atPath: path)
            } catch _ {
            }
        }
    }

    public class func get(_ aKey: String) -> Data? {
        return Disk().get(aKey)
    }

    public class func set(_ anObject: Data, forKey aKey: String) {
        Disk().set(anObject, forKey: aKey)
    }

    public func get(_ aKey: String) -> Data? {
        if let data = storedData[aKey] {
            return data
        }
        return (try? Data(contentsOf: URL(fileURLWithPath: _path(aKey))))
    }

    fileprivate func get(_ aKey: URL) -> Data? {
        guard let key = aKey.absoluteString.escape() else { return nil }

        return get(key)
    }

    fileprivate func _path(_ name: String) -> String {
        return directory.path + "/" + name
    }

    public func set(_ anObject: Data, forKey aKey: String) {
        storedData[aKey] = anObject

        let block: () -> Void = {
            do {
                try anObject.write(to: URL(fileURLWithPath: self._path(aKey)), options: [])
                self.storedData[aKey] = nil
            } catch _ {}
        }

        _ioQueue.async(execute: block)
    }

    fileprivate func set(_ anObject: Data, forKey aKey: URL) {
        guard let key = aKey.absoluteString.escape() else { return }
        set(anObject, forKey: key)
    }
}

extension Disk: ImageLoaderCache {

    public subscript (aKey: URL) -> Data? {
        get {
            var data : Data?
            _subscriptQueue.sync {
                data = self.get(aKey)
            }
            return data
        }

        set {
            _subscriptQueue.async {
                self.set(newValue!, forKey: aKey)
            }
        }
    }
}
