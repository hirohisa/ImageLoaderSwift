//
//  DiskTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/1/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest
@testable import ImageLoader

class DiskTests: ImageLoaderTests {

    func generateData() -> NSData {
        let image = UIImage(color: UIColor.blackColor(), size: CGSize(width: 1, height: 1))!
        let data = UIImageJPEGRepresentation(image, 1)!

        return data
    }

    func testSetAndGet() {
        let URL = NSURL(string: "http://test/sample")!
        let data = generateData()

        let disk = Disk()
        disk[URL] = data

        XCTAssertNotNil(disk[URL])
        XCTAssertEqual(disk[URL]!, data)
    }

    func testSetAndGetWithString() {
        let key = "1234"

        let data = generateData()

        let disk = Disk()
        disk.set(data, forKey: key)

        XCTAssertNotNil(disk.get(key))
        XCTAssertEqual(disk.get(key)!, data)
    }

    func testSetFromURLAndGetWithString() {
        let string = "http://test.com"
        let encodedString = "http%3A%2F%2Ftest.com"

        let URL = NSURL(string: string)!
        let data = generateData()

        let disk = Disk()
        disk[URL] = data

        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 2))

        XCTAssertNotNil(disk.get(encodedString))
        XCTAssertEqual(disk.get(encodedString)!, data)
    }

    func testSetAndWriteToDisk() {
        let URL = NSURL(string: "http://test/save_to_file")!
        let data = generateData()

        let disk = Disk()
        disk[URL] = data

        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 2))

        XCTAssertNotNil(disk[URL])
        XCTAssertEqual(disk[URL]!, data)
        XCTAssertNil(disk.storedData[URL.absoluteString])
    }

    func testCleanDisk() {
        let URL = NSURL(string: "http://test/save_to_file_for_clean")!
        let data = generateData()

        let disk = Disk()
        disk[URL] = data

        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 2))

        Disk.cleanUp()
        XCTAssertNil(disk[URL])
    }
}
