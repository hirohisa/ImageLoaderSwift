//
//  UIImageTests.swift
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
        context?.setFillColor(color.cgColor)
        context?.fill(frameFor1px)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }

        self.init(cgImage: cgImage)
    }
}

class UIImageTests: XCTestCase {

    // MARK: - adjusts
    func testImageAdjustsScale() {
        var image: UIImage!
        var size: CGSize!
        var adjustedSize: CGSize!
        var adjustedImage: UIImage!

        image = UIImage(color: UIColor.black(), size: CGSize(width: 100, height: 100))

        size = CGSize(width: 50, height: 50)
        adjustedSize = CGSize(width: 50, height: 50)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .scaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        size = CGSize(width: 50, height: 50)
        adjustedImage = image!.adjusts(size, scale: 2, contentMode: .scaleAspectFit)
        adjustedSize = CGSize(width: 100, height: 100)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        size = CGSize(width: 200, height: 200)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .scaleAspectFit)
        adjustedSize = CGSize(width: 100, height: 100)
        XCTAssertEqual(adjustedSize, adjustedImage.size)
    }

    func testImageAdjustsRectangleScaleAspectFit1() {
        var image: UIImage!
        var size: CGSize!
        var adjustedSize: CGSize!
        var adjustedImage: UIImage!

        image = UIImage(color: UIColor.black(), size: CGSize(width: 50, height: 30))

        size = CGSize(width: 50, height: 50)
        adjustedSize = CGSize(width: 50, height: 30)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .scaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        size = CGSize(width: 50, height: 60)
        adjustedSize = CGSize(width: 50, height: 30)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .scaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        size = CGSize(width: 60, height: 30)
        adjustedSize = CGSize(width: 50, height: 30)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .scaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size)
    }

    func testImageAdjustsRectangleScaleAspectFit2() {
        var image: UIImage!
        var size: CGSize!
        var adjustedSize: CGSize!
        var adjustedImage: UIImage!

        image = UIImage(color: UIColor.black(), size: CGSize(width: 100, height: 60))

        size = CGSize(width: 25, height: 25)
        adjustedSize = CGSize(width: 50, height: 30)
        adjustedImage = image!.adjusts(size, scale: 2, contentMode: .scaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        size = CGSize(width: 25, height: 30)
        adjustedSize = CGSize(width: 50, height: 30)
        adjustedImage = image!.adjusts(size, scale: 2, contentMode: .scaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        size = CGSize(width: 30, height: 15)
        adjustedSize = CGSize(width: 50, height: 30)
        adjustedImage = image!.adjusts(size, scale: 2, contentMode: .scaleAspectFit)
        XCTAssertEqual(adjustedSize, adjustedImage.size)
    }

    func testImageAdjustsRectangleScaleAspectFill1() {
        var image: UIImage!
        var size: CGSize!
        var adjustedSize: CGSize!
        var adjustedImage: UIImage!

        image = UIImage(color: UIColor.black(), size: CGSize(width: 100, height: 80))

        size = CGSize(width: 40, height: 40)
        adjustedSize = CGSize(width: 50, height: 40)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .scaleAspectFill)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        size = CGSize(width: 50, height: 80)
        adjustedSize = CGSize(width: 100, height: 80)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .scaleAspectFill)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        size = CGSize(width: 80, height: 40)
        adjustedSize = CGSize(width: 80, height: 64)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .scaleAspectFill)
        XCTAssertEqual(adjustedSize, adjustedImage.size)
    }

    func testImageAdjustsRectangleScaleToFill() {
        var image: UIImage!
        var size: CGSize!
        var adjustedSize: CGSize!
        var adjustedImage: UIImage!

        image = UIImage(color: UIColor.black(), size: CGSize(width: 100, height: 80))

        // Scale 1

        size = CGSize(width: 40, height: 40)
        adjustedSize = CGSize(width: 40, height: 40)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .scaleToFill)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        size = CGSize(width: 50, height: 80)
        adjustedSize = CGSize(width: 50, height: 80)
        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .scaleToFill)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        // Scale 2
        size = CGSize(width: 40, height: 40)
        adjustedSize = CGSize(width: 80, height: 80)
        adjustedImage = image!.adjusts(size, scale: 2, contentMode: .scaleToFill)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        size = CGSize(width: 50, height: 80)
        adjustedSize = CGSize(width: 100, height: 80)
        adjustedImage = image!.adjusts(size, scale: 2, contentMode: .scaleToFill)
        XCTAssertEqual(adjustedSize, adjustedImage.size)
    }

    func testImageAdjustsScaleUnsupportContentMode() {
        var image: UIImage!
        var size: CGSize!
        var adjustedSize: CGSize!
        var adjustedImage: UIImage!

        image = UIImage(color: UIColor.black(), size: CGSize(width: 100, height: 100))

        size = CGSize(width: 50, height: 50)
        adjustedSize = CGSize(width: 100, height: 100)

        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .redraw)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .center)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .top)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .left)
        XCTAssertEqual(adjustedSize, adjustedImage.size)

        adjustedImage = image!.adjusts(size, scale: 1, contentMode: .right)
        XCTAssertEqual(adjustedSize, adjustedImage.size)
    }

    func testSizeIsZeroWhenRendering() {
        let image = UIImage(color: UIColor.black(), size: CGSize(width: 100, height: 100))!
        let renderedImage = image.render(CGSize.zero)

        XCTAssertEqual(image, renderedImage)
    }

}
