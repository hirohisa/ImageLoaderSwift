//
//  SimpleViewController.swift
//  ImageLoaderSample
//
//  Created by Hirohisa Kawasaki on 10/17/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import ImageLoader

class SimpleViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var successURLButton: UIButton!
    @IBOutlet weak var failureURLButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Simple"

        imageView.backgroundColor = UIColor.black()
    }

    // MARK: - try

    @IBAction func tryLoadSuccessURL() {
        let string = "https://www.google.co.jp/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"
        tryLoad(string)
    }

    @IBAction func tryLoadFailureURL() {
        let string = "http://upload.wikimedia.org/wikipedia/commons/1/1b/Bachalpseeflowers.jpg"
        tryLoad(string)
    }

    func tryLoad(_ URL: URLLiteralConvertible) {

        testLoad(imageView, URL: URL)

    }

    func testLoad(_ imageView: UIImageView, URL: URLLiteralConvertible) {
        imageView.load(URL, placeholder: nil) { URL, image, error, cacheType in
            print("URL \(URL)")
            print("error \(error)")
            print("cacheType \(cacheType.hashValue)")
        }

    }

}

