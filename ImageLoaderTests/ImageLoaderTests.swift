//
//  ImageLoaderTests.swift
//  ImageLoaderTests
//
//  Created by Hirohisa Kawasaki on 2014/10/16.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import XCTest
import ImageLoader

extension NSURLSessionTaskState {

    func toString() -> String {
        switch self {
        case Running:
            return "Running"
        case Suspended:
            return "Suspended"
        case Canceling:
            return "Canceling"
        case Completed:
            return "Completed"
        }
    }
}

class StringTests: XCTestCase {

    func testEscape() {
        let string: String = "http://test.com"
        let valid: String = "http%3A%2F%2Ftest.com"

        XCTAssertNotEqual(string, string.escape(),
            "String cant escape, \(string.escape())")
        XCTAssertEqual(valid, string.escape(),
            "String cant escape, \(string.escape())")
    }
}

class ImageLoaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 2))
        super.tearDown()
    }

    func testConnetWithURL() {

        var URL: NSURL!
        URL = NSURL(string: "http://test/path")

        let manager: Manager = Manager()
        let loader: Loader = manager.load(URL)

        XCTAssert(loader.status == .Running, "loader's status is not running, now is \(loader.status.toString())")
        loader.completionHandler { (completedURL, image, error) -> (Void) in
            XCTAssertEqual(URL, completedURL, "URL \(URL) and completedURL \(completedURL) are not same. ")
        }
    }

    func testCancelWithURL() {

        var URL: NSURL!
        URL = NSURL(string: "http://test/path")

        let manager: Manager = Manager()
        let loader: Loader = manager.load(URL)
        manager.cancel(URL, block: nil)

        XCTAssert(loader.status == .Canceling, "loader's status is not canceling, now is \(loader.status.toString())")

    }

}
