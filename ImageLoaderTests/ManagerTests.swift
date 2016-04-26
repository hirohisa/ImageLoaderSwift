//
//  ManagerTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/1/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest

class ManagerTests: ImageLoaderTests {

    var manager: Manager!

    override func setUp() {
        super.setUp()
        manager = Manager()
    }

    override func tearDown() {
        waitForAsyncTask(5)
        super.tearDown()
    }

    func testLoad() {
        let URL = NSURL(string: "http://manager/test/load")!

        manager.load(URL)
        XCTAssert(manager.state == .Running, manager.state.toString())

        waitForAsyncTask(1.1) // wait for loading

        XCTAssert(manager.state == .Ready, manager.state.toString())
    }

    func testSuspend() {
        let URL = NSURL(string: "http://manager/test/suspend")!

        manager.suspend(URL)
        XCTAssert(manager.state == .Ready, manager.state.toString())

        let loader = manager.load(URL)

        XCTAssert(manager.state == .Running, manager.state.toString())
        XCTAssert(loader.state == .Running, loader.state.toString())

        manager.suspend(URL)

        XCTAssert(manager.state == .Running, manager.state.toString())
        XCTAssert(loader.state == .Suspended, loader.state.toString())
    }

    func testCancel() {
        let URL = NSURL(string: "http://manager/test/cancel")!

        manager.cancel(URL)
        XCTAssert(manager.state == .Ready, manager.state.toString())

        let loader = manager.load(URL)
        XCTAssert(loader.state == .Running, loader.state.toString())

        manager.cancel(URL)
        waitForAsyncTask()

        XCTAssert(manager.state == .Ready, manager.state.toString())
        XCTAssert(loader.state == .Completed, loader.state.toString())
    }

    func testCancelWhenHasBlock() {
        let URL = NSURL(string: "http://manager/test_when_has_block/cancel")!

        let block = Block(identifier: 1) { (URL, _, error, _) -> Void in
            XCTAssertTrue(false, "dont call this completion handler")
        }

        manager.cancel(URL)
        XCTAssert(manager.state == .Ready, manager.state.toString())

        let loader = manager.load(URL)
        loader.appendBlock(block)

        XCTAssert(manager.state == .Running, manager.state.toString())
        XCTAssert(loader.state == .Running, loader.state.toString())

        manager.cancel(URL, block: block)
        XCTAssert(loader.state == .Canceling, loader.state.toString())
        XCTAssertTrue(loader.blocks.isEmpty)
        waitForAsyncTask()

        XCTAssert(manager.state == .Ready, manager.state.toString())
        XCTAssert(loader.state == .Completed, loader.state.toString())
    }

    func testCancelWhenHasTwoBlocks() {
        let expectation = expectationWithDescription("wait until loader complete")
        let URL = NSURL(string: "http://manager/test/cancel")!

        let block1 = Block(identifier: 1) { (URL, _, error, _) -> Void in
            XCTAssertTrue(false, "dont call this completion handler")
        }
        let block2 = Block(identifier: 2) { (URL, _, error, _) -> Void in
            expectation.fulfill()
        }

        let loader = manager.load(URL)
        loader.appendBlock(block1)
        loader.appendBlock(block2)

        XCTAssert(manager.state == .Running, manager.state.toString())
        XCTAssert(loader.state == .Running, loader.state.toString())
        XCTAssertTrue(loader.blocks.count == 2)

        manager.cancel(URL, block: block1)
        XCTAssert(loader.state == .Running, loader.state.toString())
        XCTAssertTrue(loader.blocks.count == 1)
        XCTAssertTrue(loader.blocks.first == block2)
        waitForAsyncTask()

        XCTAssert(manager.state == .Ready, manager.state.toString())
        XCTAssert(loader.state == .Completed, loader.state.toString())

        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error)
        }
    }
}
