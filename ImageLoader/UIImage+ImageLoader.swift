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

            let decodedSize = CGSize(width: self.size.width / scale, height: self.size.height / scale)
            let ratio = size.width/decodedSize.width < size.height/decodedSize.height ? size.width/decodedSize.width : size.height/decodedSize.height

            let fitSize = CGSize(width: decodedSize.width * ratio * scale, height: decodedSize.height * ratio * scale)
            return render(fitSize)
        case .ScaleAspectFill:
            if size.width * scale > self.size.width || size.height * scale > self.size.height {
                return self
            }

            let decodedSize = CGSize(width: self.size.width / scale, height: self.size.height / scale)
            let ratio = size.width/decodedSize.width > size.height/decodedSize.height ? size.width/decodedSize.width : size.height/decodedSize.height

            let fitSize = CGSize(width: decodedSize.width * ratio * scale, height: decodedSize.height * ratio * scale)
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

        var bitmapInfoValue = CGImageGetBitmapInfo(CGImage).rawValue
        let alphaInfo = CGImageGetAlphaInfo(CGImage)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorSpaceModel = CGColorSpaceGetModel(colorSpace)

        switch (colorSpaceModel.rawValue) {
        case CGColorSpaceModel.RGB.rawValue:

            // Reference: http://stackoverflow.com/questions/23723564/which-cgimagealphainfo-should-we-use
            var info = CGImageAlphaInfo.PremultipliedFirst
            switch alphaInfo {
            case .None:
                info = CGImageAlphaInfo.NoneSkipFirst
            default:
                break
            }
            bitmapInfoValue &= ~CGBitmapInfo.AlphaInfoMask.rawValue
            bitmapInfoValue |= info.rawValue
        default:
            break
        }

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
            return UIImage(CGImage: cgImage)
        }
        
        return self
    }
}
