//
//  UIImage+ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 10/28/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

private let lock = NSRecursiveLock()

// MARK: Optimize image

extension UIImage {

    func adjusts(size: CGSize, scale: CGFloat, contentMode: UIViewContentMode) -> UIImage {
        lock.lock()
        defer { lock.unlock() }

        switch contentMode {
        case .ScaleToFill:
            if size.width * scale > self.size.width || size.height * scale > self.size.height {
                return self
            }

            let fitSize = CGSize(width: size.width * scale, height: size.height * scale)
            return render(fitSize)
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

    func render(size: CGSize) -> UIImage {
        lock.lock()
        defer { lock.unlock() }

        if size.width == 0 || size.height == 0 {
            return self
        }

        UIGraphicsBeginImageContext(size)
        drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    static func decode(data: NSData) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }

        return UIImage(data: data)

    }
}
