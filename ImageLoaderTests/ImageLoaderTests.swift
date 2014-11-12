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

class ImageLoaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testConnetWithURL() {

        let imageLoader = ImageLoader()

        var URL: NSURL!
        URL = NSURL(string: "http://test/path")

        let task = imageLoader.getImage(URL)

        XCTAssert(task!.state == .Running, "task is not running")

        task?.suspend()

        XCTAssert(task!.state == .Suspended, "task is not suspended")
    }

    func testCancelWithURL() {

        let imageLoader = ImageLoader()

        var URL: NSURL!
        URL = NSURL(string: "http://test/path")

        let task = imageLoader.getImage(URL)
        imageLoader.cancel(URL)

        XCTAssert(task!.state == .Canceling, "task is not canceling")

    }

}
