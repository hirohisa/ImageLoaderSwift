//
//  UIImageViewTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/2/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest

// extension UIImage: Equatable

extension UIImage {

    func isEqualTo(_ image: UIImage) -> Bool {
        if size == image.size {
            let ldp = cgImage?.dataProvider
            let ldt = NSData(data: ldp?.data! as! Data) as Data

            let rdp = image.cgImage?.dataProvider
            let rdt = NSData(data: rdp?.data! as! Data) as Data

            return ldt == rdt
        }

        return false
    }

}

class UIImageViewTests: ImageLoaderTests {

    let whiteImage: UIImage = {
        let imagePath = Bundle(for: UIImageViewTests.self).pathForResource("white", ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!
    }()

    let blackImage: UIImage = {
        let imagePath = Bundle(for: UIImageViewTests.self).pathForResource("black", ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!
    }()

    var imageView: UIImageView!

    override func setUp() {
        super.setUp()
        Disk.cleanUp()
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        UIImageView.imageLoader.automaticallyAdjustsSize = false
    }

    override func tearDown() {
        waitForAsyncTask(1)
        super.tearDown()
    }

    func testLoadImage() {
        let expectation = self.expectation(withDescription: "wait until loading")

        let string = "http://test/load/white"

        imageView.load(string, placeholder: nil) { URL, image, error, type in
            XCTAssertNil(error)
            XCTAssertEqual(string.imageLoaderURL, URL)
            XCTAssertTrue(image!.isEqualTo(self.whiteImage))
            expectation.fulfill()
        }

        waitForExpectations(withTimeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testLoadImageWithPlaceholder() {
        let expectation = self.expectation(withDescription: "wait until loading")

        let string = "http://test/load_with_placeholder/white"

        imageView.load(string, placeholder: self.blackImage) { URL, image, error, type in
            XCTAssertNil(error)
            XCTAssertEqual(string.imageLoaderURL, URL)
            XCTAssertTrue(image!.isEqualTo(self.whiteImage))
            expectation.fulfill()
        }
        XCTAssertTrue(imageView.image!.isEqualTo(self.blackImage))

        waitForExpectations(withTimeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testSetImageSoonAfterLoading() {
        let expectation = self.expectation(withDescription: "wait until loading")

        let string = "http://test/set_image_after_loading/white"

        imageView.load(string, placeholder: nil) { URL, image, error, type in
            XCTAssertNil(error)
            XCTAssertEqual(string.imageLoaderURL, URL)

            XCTAssertTrue(self.imageView.image!.isEqualTo(self.whiteImage))
            expectation.fulfill()
        }
        imageView.image = blackImage
        XCTAssertTrue(imageView.image!.isEqualTo(self.blackImage))

        waitForExpectations(withTimeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testLastestLoadIsAliveWhenTwiceLoad() {
        let expectation = self.expectation(withDescription: "wait until loading")

        let string1 = "http://test/lastest_load_first/black"
        let string2 = "http://test/lastest_load_second/white"

        imageView.load(string1, placeholder: nil) { URL, image, error, type in
            XCTAssertNil(image)
            XCTAssertNil(error)
        }

        imageView.load(string2, placeholder: nil) { URL, image, error, type in
            XCTAssertNil(error)
            XCTAssertTrue(image!.isEqualTo(self.whiteImage))
            expectation.fulfill()
        }

        waitForExpectations(withTimeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testTwiceLoadsInLoadingCompletion() {
        let expectation = self.expectation(withDescription: "wait until loading")

        let string = "http://test/load_first_before_twice_load/white"
        let string1 = "http://test/load_first_in_block/black"
        let string2 = "http://test/load_second_in_block/white"

        imageView.load(string, placeholder: nil) { URL, image, error, type in
            XCTAssertNil(error)
            XCTAssertTrue(image!.isEqualTo(self.whiteImage))

            self.imageView.load(string1, placeholder: nil) { URL, image, error, type in
                XCTAssertNil(image)
                XCTAssertNil(error)
            }

            self.imageView.load(string2, placeholder: nil) { URL, image, error, type in
                XCTAssertTrue(image!.isEqualTo(self.whiteImage))
                XCTAssertTrue(self.imageView.image!.isEqualTo(self.whiteImage))
                expectation.fulfill()
            }
        }

        waitForExpectations(withTimeout: 5) { error in
            XCTAssertNil(error)
        }
    }

}
