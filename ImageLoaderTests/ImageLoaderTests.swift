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

    func waitForAsyncTask(duration: NSTimeInterval = 0.1) {
        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: duration))
    }
}