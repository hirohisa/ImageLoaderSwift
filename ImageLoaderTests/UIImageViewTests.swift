//
//  UIImageViewTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/2/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest
@testable import ImageLoader

// extension UIImage: Equatable

extension UIImage {

    func isEqualTo(_ image: UIImage) -> Bool {
        if size == image.size {
            if let lcfdt = cgImage?.dataProvider?.data, let rcfdt = image.cgImage?.dataProvider?.data {
                let ldt = NSData(data: lcfdt as Data)
                let rdt = NSData(data: rcfdt as Data)
                return ldt == rdt
            }
        }

        return false
    }

}

class UIImageViewTests: ImageLoaderTestCase {

    let whiteImage: UIImage = {
        let imagePath = Bundle(for: UIImageViewTests.self).path(forResource: "white", ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!
    }()

    let blackImage: UIImage = {
        let imagePath = Bundle(for: UIImageViewTests.self).path(forResource: "black", ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!
    }()

    var imageView: UIImageView!

    override func setUp() {
        super.setUp()
        Disk().cleanUp()
        stub()
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    }

    func testLoadImage() {
        let expectation = self.expectation(description: "wait until loading")

        let string = "http://testLoadImage/white"

        imageView.load.request(with: string, onCompletion: { image, error, operation in
            XCTAssertNil(error)
            XCTAssertTrue(image!.isEqualTo(self.whiteImage))
            expectation.fulfill()
        })

        waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error)
        }
    }

    func testLoadImageUseCache() {
        let expectation = self.expectation(description: "wait until loading")

        let string = "http://testLoadImageUseCache/white"

        imageView.image = blackImage
        let loader1 = imageView.load.request(with: string)
        XCTAssertNotNil(loader1)

        sleep(3)

        XCTAssertTrue(imageView.image!.isEqualTo(self.whiteImage))

        imageView.image = blackImage
        let loader2 = imageView.load.request(with: string, onCompletion: { _, _, operation in
            XCTAssertEqual(operation, .disk)
            expectation.fulfill()
        })
        XCTAssertNil(loader2)

        sleep(1)

        XCTAssertTrue(imageView.image!.isEqualTo(self.whiteImage))

        waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error)
        }
    }

    func testLoadImageWithPlaceholder() {
        let expectation = self.expectation(description: "wait until loading")

        let string = "http://testLoadImageWithPlaceholder/white"

        imageView.image = blackImage
        imageView.load.request(with: string, onCompletion: { image, error, operation in
            XCTAssertNil(error)
            XCTAssertTrue(image!.isEqualTo(self.whiteImage))
            expectation.fulfill()
        })
        XCTAssertTrue(imageView.image!.isEqualTo(self.blackImage))

        waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error)
        }
    }

    func testSetImageSoonAfterLoading() {
        let expectation = self.expectation(description: "wait until loading")

        let string = "http://testSetImageSoonAfterLoading/white"

        imageView.load.request(with: string, onCompletion: { image, error, operation in
            XCTAssertNil(error)
            XCTAssertTrue(image!.isEqualTo(self.whiteImage))
            expectation.fulfill()
        })
        imageView.image = blackImage
        XCTAssertTrue(imageView.image!.isEqualTo(self.blackImage))

        waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error)
        }
    }

    func testLastestLoadIsAliveWhenTwiceLoad() {
        let expectation = self.expectation(description: "wait until loading")

        let string1 = "http://testLastestLoadIsAliveWhenTwiceLoad/black"
        let string2 = "http://testLastestLoadIsAliveWhenTwiceLoad/white"

        imageView.load.request(with: string1, onCompletion: { image, error, operation in
            XCTAssertNotNil(error)
        })
        imageView.load.request(with: string2, onCompletion: { image, error, operation in
            XCTAssertNil(error)
            XCTAssertTrue(image!.isEqualTo(self.whiteImage))
            expectation.fulfill()
        })

        waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error)
        }
    }

    func testLastestLoadIsAliveWhenTwiceLoadWithSameUrl() {
        let expectation = self.expectation(description: "wait until loading")

        let string = "http://testLastestLoadIsAliveWhenTwiceLoadWithSameUrl/white"

        let loader1 = imageView.load.request(with: string, onCompletion: { _,_,_  in
            XCTFail()
        })
        XCTAssertEqual(loader1?.operative.tasks.count, 1)
        let loader2 = imageView.load.request(with: string, onCompletion: { image, error, operation in
            XCTAssertNil(error)
            XCTAssertTrue(image!.isEqualTo(self.whiteImage))
            expectation.fulfill()
        })
        XCTAssertEqual(loader2?.operative.tasks.count, 1)

        XCTAssertEqual(loader1, loader2)

        waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error)
        }
    }

    func testTwiceLoadsInLoadingCompletion() {
        let expectation = self.expectation(description: "wait until loading")

        let string = "http://testTwiceLoadsInLoadingCompletion/1/white"
        let string1 = "http://testTwiceLoadsInLoadingCompletion/2/black"
        let string2 = "http://testTwiceLoadsInLoadingCompletion/1/white"

        imageView.load.request(with: string, onCompletion: { image, error, operation in
            XCTAssertNil(error)
            XCTAssertTrue(image!.isEqualTo(self.whiteImage))
            XCTAssertTrue(self.imageView.image!.isEqualTo(self.whiteImage))

            self.imageView.load.request(with: string1, onCompletion: { error,_,_ in
                XCTAssertNotNil(error)
            })
            self.imageView.load.request(with: string2, onCompletion: { image, error, operation in
                XCTAssertTrue(image!.isEqualTo(self.whiteImage))
                XCTAssertTrue(self.imageView.image!.isEqualTo(self.whiteImage))
                expectation.fulfill()
            })
        })

        waitForExpectations(timeout: 6) { error in
            XCTAssertNil(error)
        }
    }

}
