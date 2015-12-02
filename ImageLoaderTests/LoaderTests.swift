//
//  LoaderTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 11/30/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest

class LoaderTests: ImageLoaderTests {

    func testLoad() {

        let expectation = expectationWithDescription("wait until loader complete")

        var URL: NSURL!
        URL = NSURL(string: "http://test/path")

        let manager = Manager()
        let loader = manager.load(URL)

        XCTAssert(loader.state == .Running, loader.state.toString())
        loader.completionHandler { completedURL, image, error, cacheType in

            XCTAssertEqual(URL, completedURL)
            XCTAssert(manager.state == .Ready, manager.state.toString())
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error)
        }
    }

    func testRemoveAfterRunning() {

        let expectation = expectationWithDescription("wait until loader complete")

        var URL: NSURL!
        URL = NSURL(string: "http://test/remove")

        let manager = Manager()
        let loader = manager.load(URL)

        XCTAssert(loader.state == .Running, loader.state.toString())

        loader.completionHandler { completedURL, image, error, cacheType in

            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue(), {
                XCTAssertNil(manager.delegate[URL], "loader did not remove from delegate")
                expectation.fulfill()
            })
        }

        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error)
        }
    }

    func testSomeLoad() {

        var URL: NSURL!
        URL = NSURL(string: "http://test/path")

        let manager = Manager()
        let loader1 = manager.load(URL)

        URL = NSURL(string: "http://test/path2")
        let loader2 = manager.load(URL)

        XCTAssert(loader1.state == .Running, loader1.state.toString())
        XCTAssert(loader2.state == .Running, loader2.state.toString())
        XCTAssert(loader1 !== loader2)

    }


    func testSomeLoadSameURL() {

        var URL: NSURL!
        URL = NSURL(string: "http://test/path")

        let manager = Manager()
        let loader1 = manager.load(URL)

        URL = NSURL(string: "http://test/path")
        let loader2 = manager.load(URL)

        XCTAssert(loader1.state == .Running, loader1.state.toString())
        XCTAssert(loader2.state == .Running, loader2.state.toString())
        XCTAssert(loader1 === loader2)

    }

    func testLoadResponseCode404() {

        let expectation = expectationWithDescription("wait until loader complete")

        let URL = NSURL(string: "http://test/404")!

        let manager = Manager()
        let loader = manager.load(URL)

        XCTAssert(loader.state == .Running, loader.state.toString())
        loader.completionHandler { completedURL, image, error, cacheType in

            XCTAssertNil(image)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error)
        }
    }

    func testCancelAfterLoading() {

        let URL = NSURL(string: "http://test/path")!

        let manager: Manager = Manager()

        XCTAssert(manager.state == .Ready, manager.state.toString())

        manager.load(URL)
        manager.cancel(URL, block: nil)

        let loader: Loader? = manager.delegate[URL]
        XCTAssertNil(loader)

    }

    func testUseShouldKeepLoader() {
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
        XCTAssertNotNil(keepingLoader)
        XCTAssertNil(notkeepingLoader)
    }

    func testTooManyLoad() {
        let manager: Manager = Manager()
        XCTAssert(manager.state == .Ready, manager.state.toString())

        for i in 0...20 {
            let URL = "https://image/\(i)"
            manager.load(URL)
        }
        XCTAssertEqual(manager.delegate.loaders.count, 20)
    }
}
