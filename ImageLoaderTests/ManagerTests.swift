//
//  ManagerTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/1/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest

class ManagerTests: ImageLoaderTests {

    func testLoad() {
        let URL = NSURL(string: "http://manager/test/load")!

        let manager = Manager()
        manager.load(URL)

        waitForAsyncTask()

        XCTAssert(manager.state == .Running, manager.state.toString())

        waitForAsyncTask(1.1) // wait for loading

        XCTAssert(manager.state == .Ready, manager.state.toString())
    }

    func testSuspend() {
        let URL = NSURL(string: "http://manager/test/suspend")!

        let manager = Manager()
        manager.suspend(URL)
        XCTAssert(manager.state == .Ready, manager.state.toString())

        let loader = manager.load(URL)
        waitForAsyncTask()

        XCTAssert(manager.state == .Running, manager.state.toString())
        XCTAssert(loader.state == .Running, loader.state.toString())

        manager.suspend(URL)
        waitForAsyncTask()

        XCTAssert(manager.state == .Suspended, manager.state.toString())
        XCTAssert(loader.state == .Suspended, loader.state.toString())
    }

    func testCancel() {
        let URL = NSURL(string: "http://manager/test/cancel")!

        let manager = Manager()
        manager.cancel(URL)
        XCTAssert(manager.state == .Ready, manager.state.toString())

        let loader = manager.load(URL)
        waitForAsyncTask()

        XCTAssert(manager.state == .Running, manager.state.toString())
        XCTAssert(loader.state == .Running, loader.state.toString())

        let canceledLoader = manager.cancel(URL)
        XCTAssert(canceledLoader!.state == .Canceling, loader.state.toString())
        waitForAsyncTask()

        XCTAssert(manager.state == .Ready, manager.state.toString())
        XCTAssert(loader.state == .Completed, loader.state.toString())
        XCTAssert(canceledLoader!.state == .Completed, loader.state.toString())
    }

    func testCancelWhenHasBlock() {
        let URL = NSURL(string: "http://manager/test/cancel")!

        let block = Block { (URL, _, error, _) -> Void in
            XCTAssertTrue(false, "dont call this completion handler")
        }

        let manager = Manager()
        manager.cancel(URL)
        XCTAssert(manager.state == .Ready, manager.state.toString())

        let loader = manager.load(URL)
        loader.appendBlock(block)
        waitForAsyncTask()

        XCTAssert(manager.state == .Running, manager.state.toString())
        XCTAssert(loader.state == .Running, loader.state.toString())

        let canceledLoader = manager.cancel(URL, block: block)
        XCTAssert(canceledLoader!.state == .Canceling, loader.state.toString())
        XCTAssertTrue(loader.blocks.isEmpty)
        XCTAssertTrue(canceledLoader!.blocks.isEmpty)
        waitForAsyncTask()

        XCTAssert(manager.state == .Ready, manager.state.toString())
        XCTAssert(loader.state == .Completed, loader.state.toString())
        XCTAssert(canceledLoader!.state == .Completed, loader.state.toString())
    }
}
