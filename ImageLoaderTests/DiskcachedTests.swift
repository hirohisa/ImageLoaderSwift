//
//  DiskcachedTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/1/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest
@testable import ImageLoader

class DiskcachedTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSet() {
        let URL = NSURL(string: "http://test/sample")!
        let image = UIImage(color: UIColor.blackColor(), size: CGSize(width: 1, height: 1))!
        let data = UIImageJPEGRepresentation(image, 1)

        let cached = Diskcached()
        cached[URL] = data

        XCTAssertNotNil(cached[URL])
        XCTAssertEqual(cached[URL]!, data)
    }

    func testSetAndWriteToDisk() {
        let URL = NSURL(string: "http://test/save_to_file")!
        let image = UIImage(color: UIColor.blackColor(), size: CGSize(width: 1, height: 1))!
        let data = UIImageJPEGRepresentation(image, 1)

        let cached = Diskcached()
        cached[URL] = data

        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 2))

        XCTAssertNotNil(cached[URL])
        XCTAssertEqual(cached[URL]!, data)
        XCTAssertNil(cached.storedData[URL])
    }

    func testCleanDisk() {
        let URL = NSURL(string: "http://test/save_to_file_for_clean")!
        let image = UIImage(color: UIColor.blackColor(), size: CGSize(width: 1, height: 1))!
        let data = UIImageJPEGRepresentation(image, 1)

        let cached = Diskcached()
        cached[URL] = data

        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 2))

        cached.removeAllObjects()
        XCTAssertNil(cached[URL])
    }

}
