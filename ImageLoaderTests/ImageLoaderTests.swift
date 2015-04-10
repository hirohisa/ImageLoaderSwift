//
//  ImageLoaderTests.swift
//  ImageLoaderTests
//
//  Created by Hirohisa Kawasaki on 10/16/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
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

extension State {

    func toString() -> String {
        switch self {
        case .Ready:
            return "Ready"
        case Running:
            return "Running"
        case Suspended:
            return "Suspended"
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

        XCTAssert(loader.state == .Running,
            "loader's status is not running, now is \(loader.state.toString())")
        loader.completionHandler { completedURL, image, error in
            XCTAssertEqual(URL, completedURL,
                "URL \(URL) and completedURL \(completedURL) are not same. ")
            XCTAssert(manager.state == .Ready,
                "manager's state is not ready, now is \(manager.state.toString())")
        }
    }

    func testCancelWithURL() {

        var URL: NSURL!
        URL = NSURL(string: "http://test/path")

        let manager: Manager = Manager()
        let loader: Loader = manager.load(URL)
        manager.cancel(URL, block: nil)

        XCTAssert(manager.state == .Ready,
            "manager's state is not ready, now is \(manager.state.toString())")

        let loader2: Loader? = manager.delegate[URL]
        XCTAssertNil(loader2,
            "Store doesnt remove the loader, \(loader2)")

    }

}
