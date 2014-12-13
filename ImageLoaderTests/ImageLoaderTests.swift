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

        var URL: NSURL!
        URL = NSURL(string: "http://test/path")

        Manager.sharedInstance.load(URL).completionHandler { (completedURL, image, error) -> (Void) in
            XCTAssertEqual(URL, completedURL, "URL \(URL) and completedURL \(completedURL) are not same, ")
        }
    }

}
