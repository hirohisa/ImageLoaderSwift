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

    func isEqualTo(image: UIImage) -> Bool {
        if size == image.size {
            let ldp = CGImageGetDataProvider(CGImage)
            let ldt = NSData(data: CGDataProviderCopyData(ldp)!)

            let rdp = CGImageGetDataProvider(image.CGImage)
            let rdt = NSData(data: CGDataProviderCopyData(rdp)!)

            return ldt == rdt
        }

        return false
    }

}

class UIImageViewTests: ImageLoaderTests {

    let whiteImage: UIImage = {
        let imagePath = NSBundle(forClass: UIImageViewTests.self).pathForResource("white", ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!
    }()

    let blackImage: UIImage = {
        let imagePath = NSBundle(forClass: UIImageViewTests.self).pathForResource("black", ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!
    }()

    var imageView: UIImageView!

    override func setUp() {
        super.setUp()
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    }

    override func tearDown() {
        waitForAsyncTask(1)
        super.tearDown()
    }

    func testLoadImage() {
        let expectation = expectationWithDescription("wait until loading")

        let string = "http://test/load/white"

        imageView.load(string, placeholder: nil) { URL, image, error, type in
            XCTAssertNil(error)
            XCTAssertEqual(string.imageLoaderURL, URL)
            XCTAssertTrue(image!.isEqualTo(self.whiteImage))
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error)
        }
    }

    func testSetImageSoonAfterLoading() {
        let expectation = expectationWithDescription("wait until loading")

        let string = "http://test/set_image_after_loading/white"

        imageView.load(string, placeholder: nil) { URL, image, error, type in
            XCTAssertNil(error)
            XCTAssertEqual(string.imageLoaderURL, URL)

            self.waitForAsyncTask(0.1)

            XCTAssertTrue(self.imageView.image!.isEqualTo(self.whiteImage))
            expectation.fulfill()
        }
        imageView.image = blackImage
        XCTAssertTrue(imageView.image!.isEqualTo(self.blackImage))

        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error)
        }
    }

    func testLastestLoadIsAliveWhenTwiceLoad() {
        let expectation = expectationWithDescription("wait until loading")

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

        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error)
        }
    }

    func testTwiceLoadsInLoadingCompletion() {
        let expectation = expectationWithDescription("wait until loading")

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

                self.waitForAsyncTask()

                XCTAssertTrue(self.imageView.image!.isEqualTo(self.whiteImage))
                expectation.fulfill()
            }
        }


        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error)
        }
    }

}
