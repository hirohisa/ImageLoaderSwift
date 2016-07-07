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

        let expectation = self.expectation(withDescription: "wait until loader complete")

        var URL: URL!
        url = URL(string: "http://test/path")

        let manager = Manager()
        let loader = manager.load(URL)

        XCTAssert(loader.state == .running, loader.state.toString())
        loader.completionHandler { completedURL, image, error, cacheType in

            XCTAssertEqual(URL, completedURL)
            XCTAssert(manager.state == .running, manager.state.toString())
            expectation.fulfill()
        }

        waitForExpectations(withTimeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testRemoveAfterRunning() {

        let expectation = self.expectation(withDescription: "wait until loader complete")

        var URL: URL!
        url = URL(string: "http://test/remove")

        let manager = Manager()
        let loader = manager.load(URL)

        XCTAssert(loader.state == .running, loader.state.toString())

        loader.completionHandler { completedURL, image, error, cacheType in

            let time  = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.after(when: time, block: {
                XCTAssertNil(manager.delegate[URL], "loader did not remove from delegate")
                expectation.fulfill()
            })
        }

        waitForExpectations(withTimeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testSomeLoad() {

        var URL: URL!
        url = URL(string: "http://test/path")

        let manager = Manager()
        let loader1 = manager.load(URL)

        url = URL(string: "http://test/path2")
        let loader2 = manager.load(URL)

        XCTAssert(loader1.state == .running, loader1.state.toString())
        XCTAssert(loader2.state == .running, loader2.state.toString())
        XCTAssert(loader1 !== loader2)

    }


    func testSomeLoadSameURL() {

        var URL: URL!
        url = URL(string: "http://test/path")

        let manager = Manager()
        let loader1 = manager.load(URL)

        url = URL(string: "http://test/path")
        let loader2 = manager.load(URL)

        XCTAssert(loader1.state == .running, loader1.state.toString())
        XCTAssert(loader2.state == .running, loader2.state.toString())
        XCTAssert(loader1 === loader2)

    }

    func testLoadResponseCode404() {

        let expectation = self.expectation(withDescription: "wait until loader complete")

        let url = URL(string: "http://test/404")!

        let manager = Manager()
        let loader = manager.load(URL)

        XCTAssert(loader.state == .running, loader.state.toString())
        loader.completionHandler { completedURL, image, error, cacheType in

            XCTAssertNil(image)
            expectation.fulfill()
        }

        waitForExpectations(withTimeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testCancelAfterLoading() {

        let url = URL(string: "http://test/path")!

        let manager: Manager = Manager()

        XCTAssert(manager.state == .ready, manager.state.toString())

        manager.load(URL)
        manager.cancel(URL, block: nil)

        let loader: Loader? = manager.delegate[URL]
        XCTAssertNil(loader)

    }

    func testUseShouldKeepLoader() {
        let url = URL(string: "http://test/path")!

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
}
