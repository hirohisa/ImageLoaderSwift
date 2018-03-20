//
//  ImageLoaderTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/1/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest
@testable import ImageLoader

class ImageLoaderTests: ImageLoaderTestCase {

    override func tearDown() {
        sleep(2)
        super.tearDown()
    }

    func testLoad() {
        let expectation = self.expectation(description: "wait until loader complete")

        let url = URL(string: "http://example/test/load")!
        let onCompletion: (UIImage?, Error?, FetchOperation) -> Void = { _,_,_ -> Void in
            expectation.fulfill()
        }

        let loader = ImageLoader.request(with: url, onCompletion: onCompletion)
        XCTAssert(loader!.state == .running)

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testCancel() {
        let expectation = self.expectation(description: "wait until loader complete")

        let url = URL(string: "http://example/test/cancel")!
        let onCompletion: (UIImage?, Error?, FetchOperation) -> Void = { _, error, _ -> Void in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        let loader = ImageLoader.request(with: url, onCompletion: onCompletion)
        XCTAssert(loader!.state == .running)
        loader!.cancel()
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testLoadUrls() {
        let url1 = URL(string: "http://example/test/load/urls1")!
        let loader1 = ImageLoader.request(with: url1, onCompletion: { _,_,_ in })

        let url2 = URL(string: "http://example/test/load/urls2")!
        let loader2 = ImageLoader.request(with: url2, onCompletion: { _,_,_  in })

        XCTAssert(loader1!.state == .running)
        XCTAssert(loader2!.state == .running)
        XCTAssert(loader1 != loader2)
    }

    func testLoadSameUrl() {
        let url = URL(string: "http://example/test/load/same/url")!
        let loader1 = ImageLoader.request(with: url, onCompletion: { _,_,_ in })
        let loader2 = ImageLoader.request(with: url, onCompletion: { _,_,_ in })

        XCTAssert(loader1!.state == .running, loader1!.state.toString())
        XCTAssert(loader2!.state == .running, loader2!.state.toString())
         XCTAssert(loader1 == loader2)
    }

    func testLoadResponseCode404() {
        let expectation = self.expectation(description: "wait until loader complete")

        let url = URL(string: "http://example/404")!
        let _ = ImageLoader.request(with: url, onCompletion: { image, error, operation in
            XCTAssertNil(image)
            XCTAssertNotNil(error)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testCancelAfterLoading() {
        let url = URL(string: "http://example/test/cancel/after/loading")!
        let loader = ImageLoader.request(with: url, onCompletion: { _,_,_ in })
        loader!.cancel()

        let actual = ImageLoader.loaderManager.storage[url]
        XCTAssertNil(actual)
    }

}
