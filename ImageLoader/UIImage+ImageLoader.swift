//
//  UIImage+ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 10/28/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

// MARK: Optimize image

extension CGBitmapInfo {
    private var alphaInfo: CGImageAlphaInfo? {
        let info = intersect(.AlphaInfoMask)
        return CGImageAlphaInfo(rawValue: info.rawValue)
    }
}

extension UIImage {

    func adjusts(size: CGSize, scale: CGFloat, contentMode: UIViewContentMode) -> UIImage {
        switch contentMode {
        case .ScaleAspectFit:
            if size.width * scale > self.size.width || size.height * scale > self.size.height {
                return self
            }

            let downscaleSize = CGSize(width: self.size.width / scale, height: self.size.height / scale)
            let ratio = size.width/downscaleSize.width < size.height/downscaleSize.height ? size.width/downscaleSize.width : size.height/downscaleSize.height

            let fitSize = CGSize(width: downscaleSize.width * ratio * scale, height: downscaleSize.height * ratio * scale)
            return render(fitSize)
        case .ScaleAspectFill:
            if size.width * scale > self.size.width || size.height * scale > self.size.height {
                return self
            }

            let downscaleSize = CGSize(width: self.size.width / scale, height: self.size.height / scale)
            let ratio = size.width/downscaleSize.width > size.height/downscaleSize.height ? size.width/downscaleSize.width : size.height/downscaleSize.height

            let fitSize = CGSize(width: downscaleSize.width * ratio * scale, height: downscaleSize.height * ratio * scale)
            return render(fitSize)
        default:
            return self
        }
    }

    private func render(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    static func decode(data: NSData) -> UIImage? {
        let image = UIImage(data: data)

        return image?.decoded()
    }

    func decoded() -> UIImage {
        let width = CGImageGetWidth(CGImage)
        let height = CGImageGetHeight(CGImage)
        if !(width > 0 && height > 0) {
            return self
        }

        let bitsPerComponent = CGImageGetBitsPerComponent(CGImage)

        if (bitsPerComponent > 8) {
            return self
        }

        var image: UIImage?
        autoreleasepool {
            let bitmapInfoValue = CGImageGetBitmapInfo(CGImage).rawValue
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGBitmapContextCreate(
                nil,
                width,
                height,
                bitsPerComponent,
                0,
                colorSpace,
                bitmapInfoValue
            )

            let frame = CGRect(x: 0, y: 0, width: width, height: height)

            CGContextDrawImage(context, frame, CGImage)

            if let cgImage = CGBitmapContextCreateImage(context) {
                image = UIImage(CGImage: cgImage)
            }
            CGContextClearRect(context, frame)
        }

        return image ?? self
    }
}
