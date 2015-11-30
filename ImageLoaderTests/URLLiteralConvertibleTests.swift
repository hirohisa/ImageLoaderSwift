//
//  URLLiteralConvertibleTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 11/30/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest

class StringTests: XCTestCase {

    func testEscape() {
        let string = "http://test.com"
        let valid = "http%3A%2F%2Ftest.com"

        XCTAssertNotEqual(string, string.escape())
        XCTAssertEqual(valid, string.escape())
    }
}

class URLLiteralConvertibleTests: XCTestCase {

    func testEscapes() {
        let URL = "http://twitter.com/?status=Hello World".imageLoaderURL
        let valid = NSURL(string: "http://twitter.com/?status=Hello%20World")!

        XCTAssertEqual(URL, valid)
    }

    func testConvertImageLoaderURL() {
        let string = "https://host/path"
        let URLString = string.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        let URL = NSURL(string: URLString)!
        let components = NSURLComponents(string: URLString)!

        XCTAssertEqual(string.imageLoaderURL, URL)
        XCTAssertEqual(string.imageLoaderURL.absoluteString, URLString)

        XCTAssertEqual(URL.imageLoaderURL, URL)
        XCTAssertEqual(URL.imageLoaderURL.absoluteString, URLString)

        XCTAssertEqual(components.imageLoaderURL, URL)
        XCTAssertEqual(components.imageLoaderURL.absoluteString, URLString)
    }

    func testConvertImageLoaderURLIfNeededPercentEncoding() {
        let string = "https://host/path?query=１枚目"
        let URLString = string.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        let URL = NSURL(string: URLString)!
        let components = NSURLComponents(string: URLString)!

        XCTAssertEqual(string.imageLoaderURL, URL)
        XCTAssertEqual(string.imageLoaderURL.absoluteString, URLString)

        XCTAssertEqual(URL.imageLoaderURL, URL)
        XCTAssertEqual(URL.imageLoaderURL.absoluteString, URLString)

        XCTAssertEqual(components.imageLoaderURL, URL)
        XCTAssertEqual(components.imageLoaderURL.absoluteString, URLString)
    }
}