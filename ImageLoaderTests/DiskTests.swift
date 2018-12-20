//
//  DiskTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/1/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest
@testable import ImageLoader

class DiskTests: ImageLoaderTestCase {

    func testSetAndGet() {
        let url = URL(string: "http://test/sample")!
        let data = generateData()

        let disk = Disk()
        disk.set(data, forKey: url)

        let actual = disk.get(url)

        XCTAssertNotNil(actual)
        XCTAssertEqual(actual, data)
    }

    func testSetAndGetWithString() {
        let key = "1234"

        let data = generateData()

        let disk = Disk()
        disk.set(data, forKey: key)

        XCTAssertNotNil(disk.get(key))
        XCTAssertEqual(disk.get(key)!, data)
    }

    func testSetFromURLAndGetWithString() {
        let string = "http://test.com"
        let encodedString = "http%3A%2F%2Ftest%2Ecom"

        let url = URL(string: string)!
        let data = generateData()

        let disk = Disk()
        disk.set(data, forKey: url)

        sleep(1)

        XCTAssertNotNil(disk.get(encodedString))
        XCTAssertEqual(disk.get(encodedString)!, data)
    }

    func testSetAndWriteToDisk() {
        let url = URL(string: "http://test/save_to_file")!
        let key = url.absoluteString.escape()!
        let data = generateData()

        let disk = Disk()
        disk.set(data, forKey: url)
        XCTAssertNotNil(disk.storage[key])

        sleep(1)

        let actual = disk.get(url)

        XCTAssertNotNil(actual)
        XCTAssertEqual(actual, data)
        XCTAssertNil(disk.storage[key])
    }

    func testCleanDisk() {
        let url = URL(string: "http://test/save_to_file_for_clean")!
        let data = generateData()

        let disk = Disk()
        disk.set(data, forKey: url)

        sleep(1)
        disk.cleanUp()
        sleep(1)

        XCTAssertNil(disk.get(url))
    }

    func generateData() -> Data {
        let image = UIImage(color: UIColor.black, size: CGSize(width: 1, height: 1))!
        let data = image.jpegData(compressionQuality: 1)!

        return data
    }

}
