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
        let url = "http://twitter.com/?status=Hello World".imageLoaderURL
        let valid = URL(string: "http://twitter.com/?status=Hello%20World")!

        XCTAssertEqual(URL, valid)
    }

    func testConvertImageLoaderURL() {
        let string = "https://host/path"
        let URLString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: URLString)!
        let components = URLComponents(string: URLString)!

        XCTAssertEqual(string.imageLoaderURL, URL)
        XCTAssertEqual(string.imageLoaderURL.absoluteString, URLString)

        XCTAssertEqual(URL.imageLoaderURL, URL)
        XCTAssertEqual(URL.imageLoaderURL.absoluteString, URLString)

        XCTAssertEqual(components.imageLoaderURL, URL)
        XCTAssertEqual(components.imageLoaderURL.absoluteString, URLString)
    }

    func testConvertImageLoaderURLIfNeededPercentEncoding() {
        let string = "https://host/path?query=１枚目"
        let URLString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: URLString)!
        let components = URLComponents(string: URLString)!

        XCTAssertEqual(string.imageLoaderURL, URL)
        XCTAssertEqual(string.imageLoaderURL.absoluteString, URLString)

        XCTAssertEqual(URL.imageLoaderURL, URL)
        XCTAssertEqual(URL.imageLoaderURL.absoluteString, URLString)

        XCTAssertEqual(components.imageLoaderURL, URL)
        XCTAssertEqual(components.imageLoaderURL.absoluteString, URLString)
    }
}
