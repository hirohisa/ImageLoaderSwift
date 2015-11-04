//
//  ImageLoaderExtensionTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 10/15/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest
@testable import ImageLoader

extension UIImage {
    public convenience init?(color: UIColor) {
        self.init(color: color, size: CGSize(width: 1, height: 1))
    }

    public convenience init?(color: UIColor, size: CGSize) {
        let frameFor1px = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(frameFor1px.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, frameFor1px)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let CGImage = image.CGImage else {
            return nil
        }

        self.init(CGImage: CGImage)
    }
}

class ImageLoaderExtensionTests: XCTestCase {

    func testImageAdjustsScale() {
        var image: UIImage!
        var size: CGSize!
        var adjustedSize: CGSize!
        var adjustedImage: UIImage!

        image = UIImage(color: UIColor.blackColor(), size: CGSize(width: 100, height: 100))

        size = CGSize(width: 50, height: 50)
        adjustedSize = CGSize(width: 50, height: 50)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .ScaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size, "adjust size is failed")

        size = CGSize(width: 50, height: 50)
        adjustedImage = image!.adjusts(size, scale: 2, contentMode: .ScaleAspectFit)
        adjustedSize = CGSize(width: 100, height: 100)
        XCTAssertEqual(adjustedSize, adjustedImage.size, "adjust size is failed")

        size = CGSize(width: 200, height: 200)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .ScaleAspectFit)
        adjustedSize = CGSize(width: 100, height: 100)
        XCTAssertEqual(adjustedSize, adjustedImage.size, "adjust size is failed")
    }

    func testImageAdjustsRectangleAspectFitScale1() {
        var image: UIImage!
        var size: CGSize!
        var adjustedSize: CGSize!
        var adjustedImage: UIImage!

        image = UIImage(color: UIColor.blackColor(), size: CGSize(width: 50, height: 30))

        size = CGSize(width: 50, height: 50)
        adjustedSize = CGSize(width: 50, height: 30)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .ScaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size, "adjust size is failed")

        size = CGSize(width: 50, height: 60)
        adjustedSize = CGSize(width: 50, height: 30)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .ScaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size, "adjust size is failed")

        size = CGSize(width: 60, height: 30)
        adjustedSize = CGSize(width: 50, height: 30)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .ScaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size, "adjust size is failed")
    }

    func testImageAdjustsRectangleAspectFitScale2() {
        var image: UIImage!
        var size: CGSize!
        var adjustedSize: CGSize!
        var adjustedImage: UIImage!

        image = UIImage(color: UIColor.blackColor(), size: CGSize(width: 100, height: 60))

        size = CGSize(width: 25, height: 25)
        adjustedSize = CGSize(width: 50, height: 30)
        adjustedImage = image!.adjusts(size, scale: 2, contentMode: .ScaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size, "adjust size is failed")

        size = CGSize(width: 25, height: 30)
        adjustedSize = CGSize(width: 50, height: 30)
        adjustedImage = image!.adjusts(size, scale: 2, contentMode: .ScaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size, "adjust size is failed")

        size = CGSize(width: 30, height: 15)
        adjustedSize = CGSize(width: 50, height: 30)
        adjustedImage = image!.adjusts(size, scale: 2, contentMode: .ScaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size, "adjust size is failed")
    }

}
