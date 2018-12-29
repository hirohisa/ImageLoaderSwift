//
//  UIImage+ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 10/28/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

private let lock = NSRecursiveLock()

// MARK: Optimize image

extension UIImage {

    func adjust(_ size: CGSize, scale: CGFloat, contentMode: UIView.ContentMode) -> UIImage {
        lock.lock()
        defer { lock.unlock() }

        if images?.count ?? 0 > 1 {
            return self
        }

        switch contentMode {
        case .scaleToFill:
            if size.width * scale > self.size.width || size.height * scale > self.size.height {
                return self
            }

            let fitSize = CGSize(width: size.width * scale, height: size.height * scale)
            return render(fitSize)
        case .scaleAspectFit:
            if size.width * scale > self.size.width || size.height * scale > self.size.height {
                return self
            }

            let downscaleSize = CGSize(width: self.size.width / scale, height: self.size.height / scale)
            let ratio = size.width/downscaleSize.width < size.height/downscaleSize.height ? size.width/downscaleSize.width : size.height/downscaleSize.height

            let fitSize = CGSize(width: downscaleSize.width * ratio * scale, height: downscaleSize.height * ratio * scale)
            return render(fitSize)
        case .scaleAspectFill:
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

    func render(_ size: CGSize) -> UIImage {
        lock.lock()
        defer { lock.unlock() }

        if size.width == 0 || size.height == 0 {
            return self
        }

        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    internal static func process(data: Data) -> UIImage? {
        switch data.fileType {
        case .gif:
            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
            let result = source.process()
            return UIImage.animatedImage(with: result.images, duration: result.duration)
        case .png, .jpeg, .tiff, .webp, .Unknown:
            return UIImage(data: data)
        }
    }

    static func decode(_ data: Data) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }

        return UIImage(data: data)
    }
}
