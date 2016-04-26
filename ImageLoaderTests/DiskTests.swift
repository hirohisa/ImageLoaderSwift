//
//  DiskTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/1/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest
@testable import ImageLoader

class DiskTests: XCTestCase {

    func generateData() -> NSData {
        let image = UIImage(color: UIColor.blackColor(), size: CGSize(width: 1, height: 1))!
        let data = UIImageJPEGRepresentation(image, 1)!

        return data
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSet() {
        let URL = NSURL(string: "http://test/sample")!
        let data = generateData()

        let disk = Disk()
        disk[URL] = data

        XCTAssertNotNil(disk[URL])
        XCTAssertEqual(disk[URL]!, data)
    }

    func testSetAndWriteToDisk() {
        let URL = NSURL(string: "http://test/save_to_file")!
        let data = generateData()

        let disk = Disk()
        disk[URL] = data

        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 2))

        XCTAssertNotNil(disk[URL])
        XCTAssertEqual(disk[URL]!, data)
        XCTAssertNil(disk.storedData[URL])
    }

    func testCleanDisk() {
        let URL = NSURL(string: "http://test/save_to_file_for_clean")!
        let data = generateData()

        let disk = Disk()
        disk[URL] = data

        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 2))

        disk.removeAllObjects()
        XCTAssertNil(disk[URL])
    }
}
