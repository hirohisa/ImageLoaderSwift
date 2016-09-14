//
//  ImageLoaderTests.swift
//  ImageLoaderTests
//
//  Created by Hirohisa Kawasaki on 10/16/14.
//  Copyright © 2014 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import XCTest
@testable import ImageLoader
import OHHTTPStubs

extension URLSessionTask.State {

    func toString() -> String {
        switch self {
        case .running:
            return "Running"
        case .suspended:
            return "Suspended"
        case .canceling:
            return "Canceling"
        case .completed:
            return "Completed"
        }
    }
}

extension State {

    func toString() -> String {
        switch self {
        case .ready:
            return "Ready"
        case .running:
            return "Running"
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
        OHHTTPStubs.stubRequests(passingTest: { request -> Bool in
            return true
        }, withStubResponse: { request in
            var data = Data()
            var statusCode = Int32(200)
            if let path = request.url?.path , !path.isEmpty {
                switch path {
                case _ where path.hasSuffix("white"):
                    let imagePath = Bundle(for: type(of: self)).path(forResource: "white", ofType: "png")!
                    data = UIImagePNGRepresentation(UIImage(contentsOfFile: imagePath)!)!
                case _ where path.hasSuffix("black"):
                    let imagePath = Bundle(for: type(of: self)).path(forResource: "black", ofType: "png")!
                    data = UIImagePNGRepresentation(UIImage(contentsOfFile: imagePath)!)!
                default:
                    if let i = Int(path) , 400 <= i && i < 600 {
                        statusCode = Int32(i)
                    }
                }
            }

            let response = OHHTTPStubsResponse(data: data, statusCode: statusCode, headers: nil)
            response.responseTime = 1
            return response
        })
    }

    func removeOHHTTPStubs() {
        OHHTTPStubs.removeAllStubs()
    }

    func waitForAsyncTask(_ duration: TimeInterval = 0.01) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: duration))
    }
}
