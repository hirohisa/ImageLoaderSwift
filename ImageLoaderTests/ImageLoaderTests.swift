//
//  ImageLoaderTests.swift
//  ImageLoaderTests
//
//  Created by Hirohisa Kawasaki on 10/16/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import XCTest
@testable import ImageLoader
import OHHTTPStubs

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

class ImageLoaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setUpOHHTTPStubs()
    }

    override func tearDown() {
        removeOHHTTPStubs()
        super.tearDown()

    }

    func setUpOHHTTPStubs() {
        OHHTTPStubs.stubRequestsPassingTest({ request -> Bool in
            return true
            }, withStubResponse: { request in
                let data = try! NSJSONSerialization.dataWithJSONObject([:], options: [])
                let response = OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)

                if let path = request.URL?.path as String? {
                    if let i = Int(path) where 400 <= i && i < 600 {
                        response.statusCode = Int32(i)
                    }
                }

                response.responseTime = 1

                return response
        })
    }

    func removeOHHTTPStubs() {
        OHHTTPStubs.removeAllStubs()
    }

    func testLoaderRunWithURL() {

        let expectation = expectationWithDescription("wait until loader complete")

        var URL: NSURL!
        URL = NSURL(string: "http://test/path")

        let manager = Manager()
        let loader = manager.load(URL)

        XCTAssert(loader.state == .Running,
            "loader's status is not running, now is \(loader.state.toString())")
        loader.completionHandler { completedURL, image, error, cacheType in

            XCTAssertEqual(URL, completedURL,
                "URL \(URL) and completedURL \(completedURL) are not same. ")
            XCTAssert(manager.state == .Ready,
                "manager's state is not ready, now is \(manager.state.toString())")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "loader did not finish")
        }
    }

    func testLoaderRemoveAfterRunning() {

        let expectation = expectationWithDescription("wait until loader complete")

        var URL: NSURL!
        URL = NSURL(string: "http://test/remove")

        let manager = Manager()
        let loader = manager.load(URL)

        XCTAssert(loader.state == .Running,
            "loader's status is not running, now is \(loader.state.toString())")
        loader.completionHandler { completedURL, image, error, cacheType in

            XCTAssertNil(manager.delegate[URL], "loader did not remove from delegate")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "loader did not finish")
        }
    }

    func testLoadersRunWithURL() {

        var URL: NSURL!
        URL = NSURL(string: "http://test/path")

        let manager = Manager()
        let loader1 = manager.load(URL)

        URL = NSURL(string: "http://test/path2")
        let loader2 = manager.load(URL)

        XCTAssert(loader1.state == .Running,
            "loader's status is not running, now is \(loader1.state.toString())")
        XCTAssert(loader2.state == .Running,
            "loader's status is not running, now is \(loader2.state.toString())")
        XCTAssert(loader1 !== loader2,
            "loaders are same")

    }


    func testLoadersRunWithSameURL() {

        var URL: NSURL!
        URL = NSURL(string: "http://test/path")

        let manager = Manager()
        let loader1 = manager.load(URL)

        URL = NSURL(string: "http://test/path")
        let loader2 = manager.load(URL)

        XCTAssert(loader1.state == .Running,
            "loader's status is not running, now is \(loader1.state.toString())")
        XCTAssert(loader2.state == .Running,
            "loader's status is not running, now is \(loader2.state.toString())")
        XCTAssert(loader1 === loader2,
            "loaders are not same")

    }

    func testLoaderRunWith404() {

        let expectation = expectationWithDescription("wait until loader complete")

        let URL = NSURL(string: "http://test/404")!

        let manager = Manager()
        let loader = manager.load(URL)

        XCTAssert(loader.state == .Running,
            "loader's status is not running, now is \(loader.state.toString())")
        loader.completionHandler { completedURL, image, error, cacheType in

            XCTAssertNil(image,
                "image exist in completion block when status code is 404")

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "loader did not finish")
        }
    }

    func testLoaderCancelWithURL() {

        let URL = NSURL(string: "http://test/path")!

        let manager: Manager = Manager()

        XCTAssert(manager.state == .Ready,
            "manager's state is not ready, now is \(manager.state.toString())")

        manager.load(URL)
        manager.cancel(URL, block: nil)

        let loader: Loader? = manager.delegate[URL]
        XCTAssertNil(loader,
            "Store doesnt remove the loader, \(loader)")

    }

    func testLoaderShouldKeepLoader() {
        let URL = NSURL(string: "http://test/path")!

        let keepingManager = Manager()
        keepingManager.shouldKeepLoader = true
        let notkeepingManager = Manager()
        notkeepingManager.shouldKeepLoader = false

        keepingManager.load(URL)
        notkeepingManager.load(URL)

        keepingManager.cancel(URL)
        notkeepingManager.cancel(URL)

        let keepingLoader: Loader? = keepingManager.delegate[URL]
        let notkeepingLoader: Loader? = notkeepingManager.delegate[URL]
        XCTAssertNotNil(keepingLoader,
            "property `shouldKeepLoader is true` doesnt work normally, \(keepingLoader)")
        XCTAssertNil(notkeepingLoader,
            "property `shouldKeepLoader is false` doesnt work normally, \(notkeepingLoader)")
    }

    func testTooManyLoaderRun() {
        let manager: Manager = Manager()

        XCTAssert(manager.state == .Ready,
            "manager's state is not ready, now is \(manager.state.toString())")

        for i in 0...100 {
            let URL = "https://image/\(i)"
            manager.load(URL)
        }
        XCTAssertEqual(manager.delegate.loaders.count, 100)
    }
}

class StringTests: XCTestCase {

    func testEscape() {
        let string = "http://test.com"
        let valid = "http%3A%2F%2Ftest.com"

        XCTAssertNotEqual(string, string.escape(),
            "String cant escape, \(string.escape())")
        XCTAssertEqual(valid, string.escape(),
            "String cant escape, \(string.escape())")
    }
}

class URLLiteralConvertibleTests: XCTestCase {

    func testEscapes() {
        let URL = "http://twitter.com/?status=Hello World".imageLoaderURL
        let valid = NSURL(string: "http://twitter.com/?status=Hello%20World")!

        XCTAssertEqual(URL, valid, "result that \(URL) is escaped is failed.")
    }
    
}
