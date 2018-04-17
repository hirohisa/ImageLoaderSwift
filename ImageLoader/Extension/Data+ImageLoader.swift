//
//  Data+ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 4/17/18.
//  Copyright © 2018 Hirohisa Kawasaki. All rights reserved.
//

import Foundation

extension Data {

    enum FileType {
        case png
        case jpeg
        case gif
        case tiff
        case webp
        case Unknown
    }

    internal var fileType: FileType {
        let fileHeader = getFileHeader(capacity: 2)
        // https://en.wikipedia.org/wiki/List_of_file_signatures
        switch fileHeader {
        case [0x47, 0x49]:
            return .gif
        case [0xFF, 0xD8]:
            // FF D8 FF DB
            // FF D8 FF E0
            // FF D8 FF E1
            return .jpeg
        case [0x89, 0x50]:
            // 89 50 4E 47
            return .png
        default:
            return .Unknown
        }
    }

    internal func getFileHeader(capacity: Int) -> [UInt8] {

        // https://developer.apple.com/documentation/swift/unsafemutablepointer
        var pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        // malloc: *** error for object 0x60c00001af32: pointer being freed was not allocated
        // defer { pointer.deallocate() }
        (self as NSData).getBytes(pointer, length: capacity)

        var header = [UInt8]()
        for _ in 0 ..< capacity {
            header.append(pointer.pointee)
            pointer += 1
        }

        return header
    }

}
