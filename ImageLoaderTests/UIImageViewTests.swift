//
//  UIImageViewTests.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 12/2/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import XCTest

// extension UIImage: Equatable

func ==(lhs: UIImage, rhs: UIImage) -> Bool {
    if lhs.size == rhs.size {
        let ldp = CGImageGetDataProvider(lhs.CGImage)
        let ldt = NSData(data: CGDataProviderCopyData(ldp)!)

        let rdp = CGImageGetDataProvider(rhs.CGImage)
        let rdt = NSData(data: CGDataProviderCopyData(rdp)!)

        return ldt == rdt
    }

    return false
}

class UIImageViewTests: ImageLoaderTests {
}
