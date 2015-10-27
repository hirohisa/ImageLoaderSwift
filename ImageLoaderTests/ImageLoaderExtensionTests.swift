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

    func testImageAdjusts() {
        let size = CGSize(width: 50, height: 50)
        let image = UIImage(color: UIColor.blackColor(), size: size)

        var adjustedImage = image!.adjusts(size, scale: 1)
        var adjustedSize = CGSize(width: 50, height: 50)
        XCTAssertEqual(adjustedSize, adjustedImage.size, "adjust size is failed")

        adjustedImage = image!.adjusts(size, scale: 2)
        adjustedSize = CGSize(width: 100, height: 100)
        XCTAssertEqual(adjustedSize, adjustedImage.size, "adjust size is failed")

    }
}
