//
//  DiskTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/1/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest
@testable import ImageLoader

class DiskTests: ImageLoaderTests {

    func generateData() -> Data {
        let image = UIImage(color: UIColor.black, size: CGSize(width: 1, height: 1))!
        let data = UIImageJPEGRepresentation(image, 1)!

        return data
    }

    func testSetAndGet() {
        let url = URL(string: "http://test/sample")!
        let data = generateData()

        let disk = Disk()
        disk[url] = data

        XCTAssertNotNil(disk[url])
        XCTAssertEqual(disk[url]!, data)
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
        disk[url] = data

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2))

        XCTAssertNotNil(disk.get(encodedString))
        XCTAssertEqual(disk.get(encodedString)!, data)
    }

    func testSetAndWriteToDisk() {
        let url = URL(string: "http://test/save_to_file")!
        let data = generateData()

        let disk = Disk()
        disk[url] = data

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2))

        XCTAssertNotNil(disk[url])
        XCTAssertEqual(disk[url]!, data)
        XCTAssertNil(disk.storedData[url.absoluteString])
    }

    func testCleanDisk() {
        let url = URL(string: "http://test/save_to_file_for_clean")!
        let data = generateData()

        let disk = Disk()
        disk[url] = data

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2))

        Disk.cleanUp()
        XCTAssertNil(disk[url])
    }
}
