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
        let valid = "http%3A%2F%2Ftest%2Ecom"

        XCTAssertNotEqual(string, string.escape())
        XCTAssertEqual(valid, string.escape())
    }
}

class URLLiteralConvertibleTests: XCTestCase {

    func testEscapes() {
        let url = "http://twitter.com/?status=Hello World".imageLoaderURL
        let valid = URL(string: "http://twitter.com/?status=Hello%20World")!

        XCTAssertEqual(url, valid)
    }

    func testConvertImageLoaderURL() {
        let string = "https://host/path"
        let urlString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlString)!
        let components = URLComponents(string: urlString)!

        XCTAssertEqual(string.imageLoaderURL, url)
        XCTAssertEqual(string.imageLoaderURL!.absoluteString, urlString)

        XCTAssertEqual(url.imageLoaderURL, url)
        XCTAssertEqual(url.imageLoaderURL!.absoluteString, urlString)

        XCTAssertEqual(components.imageLoaderURL, url)
        XCTAssertEqual(components.imageLoaderURL!.absoluteString, urlString)
    }

    func testConvertImageLoaderURLIfNeededPercentEncoding() {
        let string = "https://host/path?query=１枚目"
        let urlString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlString)!
        let components = URLComponents(string: urlString)!

        XCTAssertEqual(string.imageLoaderURL, url)
        XCTAssertEqual(string.imageLoaderURL!.absoluteString, urlString)

        XCTAssertEqual(url.imageLoaderURL, url)
        XCTAssertEqual(url.imageLoaderURL!.absoluteString, urlString)

        XCTAssertEqual(components.imageLoaderURL, url)
        XCTAssertEqual(components.imageLoaderURL!.absoluteString, urlString)
    }
}
