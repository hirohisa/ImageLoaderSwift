//
//  ImageLoaderTestCase.swift
//  ImageLoaderTests
//
//  Created by Hirohisa Kawasaki on 10/16/14.
//  Copyright © 2014 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import XCTest
@testable import ImageLoader

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
        @unknown default:
            return "Unknown"
        }
    }
}

class ImageLoaderTestCase: XCTestCase {

    func stub() {
        URLSessionConfiguration.swizzleDefaultToMock()
    }

    func sleep(_ duration: TimeInterval = 0.01) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: duration))
    }
}

extension URLSessionConfiguration {

    class func swizzleDefaultToMock() {
        let defaultSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.default))
        let swizzledDefaultSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.mock))
        method_exchangeImplementations(defaultSessionConfiguration!, swizzledDefaultSessionConfiguration!)
    }

    @objc private dynamic class var mock: URLSessionConfiguration {
        let configuration = self.mock
        configuration.protocolClasses?.insert(URLProtocolMock.self, at: 0)
        URLProtocol.registerClass(URLProtocolMock.self)
        return configuration
    }
}

public class URLProtocolMock: URLProtocol {

    override public class func canInit(with request:URLRequest) -> Bool {
        return true
    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override public func startLoading() {
        let delay: Double = 1.0
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            if let error = self.makeError() {
                self.client?.urlProtocol(self, didFailWithError: error)
                return
            }

            self.client?.urlProtocol(self, didLoad: self.makeResponse())
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override public func stopLoading() {}

    private func makeResponse() -> Data {
        var data = Data()
        if let path = request.url?.path , !path.isEmpty {
            switch path {
            case _ where path.hasSuffix("white"):
                let imagePath = Bundle(for: type(of: self)).path(forResource: "white", ofType: "png")!
                data = UIImage(contentsOfFile: imagePath)!.pngData()!
            case _ where path.hasSuffix("black"):
                let imagePath = Bundle(for: type(of: self)).path(forResource: "black", ofType: "png")!
                data = UIImage(contentsOfFile: imagePath)!.pngData()!
            default:
                break
            }
        }

        return data
    }

    private func makeError() -> Error? {
        if let path = request.url?.path , !path.isEmpty {
            if let statusCode = Int(path) , 400 <= statusCode && statusCode < 600 {
                return NSError(domain: "Imageloader", code: statusCode, userInfo: [NSLocalizedFailureReasonErrorKey: "internet error with stub"])
            }
        }
        return nil
    }

}
