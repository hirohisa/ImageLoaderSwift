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

        imageView.backgroundColor = UIColor.black
    }

    // MARK: - try

    @IBAction func tryLoadSuccessURL() {
        let string = "https://www.google.co.jp/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"
        tryLoad(URL(string: string)!)
    }

    @IBAction func tryLoadFailureURL() {
        let string = "http://upload.wikimedia.org/wikipedia/commons/1/1b/Bachalpseeflowers.jpg"
        tryLoad(URL(string: string)!)
    }

    func tryLoad(_ url: URL) {
        imageView.load.request(with: url, onCompletion: { _, error, _ in
            print("error \(String(describing: error))")
        })
    }

}

