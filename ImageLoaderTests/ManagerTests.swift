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
        let url = URL(string: "http://manager/test/load")!

        let _ = manager.load(url)
        XCTAssert(manager.state == .running, manager.state.toString())

        waitForAsyncTask(1.1) // wait for loading

        XCTAssert(manager.state == .ready, manager.state.toString())
    }

    func testSuspend() {
        let url = URL(string: "http://manager/test/suspend")!

        let _ = manager.suspend(url)
        XCTAssert(manager.state == .ready, manager.state.toString())

        let loader = manager.load(url)

        XCTAssert(manager.state == .running, manager.state.toString())
        XCTAssert(loader.state == .running, loader.state.toString())

        let _ = manager.suspend(url)

        XCTAssert(manager.state == .running, manager.state.toString())
        XCTAssert(loader.state == .suspended, loader.state.toString())
    }

    func testCancel() {
        let url = URL(string: "http://manager/test/cancel")!

        manager.cancel(url)
        XCTAssert(manager.state == .ready, manager.state.toString())

        let loader = manager.load(url)
        XCTAssert(loader.state == .running, loader.state.toString())

        manager.cancel(url)
        waitForAsyncTask()

        XCTAssert(manager.state == .ready, manager.state.toString())
        XCTAssert(loader.state == .completed, loader.state.toString())
    }

    func testCancelWhenHasBlock() {
        let url = URL(string: "http://manager/test_when_has_block/cancel")!

        let block = Block(identifier: 1) { _ -> Void in
            XCTAssertTrue(false, "dont call this completion handler")
        }

        manager.cancel(url)
        XCTAssert(manager.state == .ready, manager.state.toString())

        let loader = manager.load(url)
        let _ = loader.appendBlock(block)

        XCTAssert(manager.state == .running, manager.state.toString())
        XCTAssert(loader.state == .running, loader.state.toString())

        manager.cancel(url, block: block)
        XCTAssert(loader.state == .canceling, loader.state.toString())
        XCTAssertTrue(loader.blocks.isEmpty)
        waitForAsyncTask()

        XCTAssert(manager.state == .ready, manager.state.toString())
    }

    func testCancelWhenHasTwoBlocks() {
        let expectation = self.expectation(description: "wait until loader complete")
        let url = URL(string: "http://manager/test/cancel")!

        let block1 = Block(identifier: 1) { _ -> Void in
            XCTAssertTrue(false, "dont call this completion handler")
        }
        let block2 = Block(identifier: 2) { _ -> Void in
            expectation.fulfill()
        }

        let loader = manager.load(url)
        let _ = loader.appendBlock(block1)
        let _ = loader.appendBlock(block2)

        XCTAssert(manager.state == .running, manager.state.toString())
        XCTAssert(loader.state == .running, loader.state.toString())
        XCTAssertTrue(loader.blocks.count == 2)

        manager.cancel(url, block: block1)
        XCTAssert(loader.state == .running, loader.state.toString())
        XCTAssertTrue(loader.blocks.count == 1)
        XCTAssertTrue(loader.blocks.first == block2)
        waitForAsyncTask()

        XCTAssert(manager.state == .ready, manager.state.toString())
        XCTAssert(loader.state == .completed, loader.state.toString())

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
}
