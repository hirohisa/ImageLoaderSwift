//
//  NSURL.swift
//  ImageLoaderExample
//
//  Created by Hirohisa Kawasaki on 2014/12/18.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

import Foundation

extension NSURL {

    class func imageURL(index: Int) -> NSURL {

        var number: NSString = index.description
        while (number.length < 3) {
            number = "0\(number)"
        }
        let string: String = "https://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage\(number).jpg"

        return NSURL(string: string)!
    }

}