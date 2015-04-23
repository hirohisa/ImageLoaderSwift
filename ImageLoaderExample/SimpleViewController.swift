//
//  SimpleViewController.swift
//  ImageLoaderSample
//
//  Created by Hirohisa Kawasaki on 10/17/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import ImageLoader

extension UIButton {
    convenience init(title: String, highlightedColor: UIColor) {
        self.init()
        frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        setTitle(title, forState: .Normal)
        setTitleColor(UIColor.blackColor(), forState: .Normal)
        setTitleColor(highlightedColor, forState: .Highlighted)
    }
}

class SimpleViewController: UIViewController {

    let imageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)

        return imageView
    }()

    let successURLButton = UIButton(title: "success", highlightedColor: UIColor.greenColor())
    let failureURLButton = UIButton(title: "failure", highlightedColor: UIColor.redColor())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()

        imageView.center = CGPoint(
            x: CGRectGetWidth(view.frame)/2,
            y: CGRectGetHeight(view.frame)/2
        )
        view.addSubview(imageView)

        configureButtons()

        tryLoadSuccessURL()
    }

    // MARK: - view

    func configureButtons() {
        successURLButton.center = CGPoint(
            x: CGRectGetWidth(view.frame)/2 - 50,
            y: CGRectGetHeight(view.frame)/2 + 200
        )
        failureURLButton.center = CGPoint(
            x: CGRectGetWidth(view.frame)/2 + 50,
            y: CGRectGetHeight(view.frame)/2 + 200
        )
        view.addSubview(successURLButton)
        view.addSubview(failureURLButton)

        successURLButton.addTarget(self, action: Selector("tryLoadSuccessURL"), forControlEvents: .TouchUpInside)
        failureURLButton.addTarget(self, action: Selector("tryLoadFailureURL"), forControlEvents: .TouchUpInside)
    }

    // MARK: - try

    func tryLoadSuccessURL() {
        let URL = NSURL(string: "http://upload.wikimedia.org/wikipedia/commons/1/1a/Bachalpseeflowers.jpg")!
        tryLoad(URL)
    }

    func tryLoadFailureURL() {
        let URL = NSURL(string: "http://upload.wikimedia.org/wikipedia/commons/1/1b/Bachalpseeflowers.jpg")!
        tryLoad(URL)
    }

    func tryLoad(URL: NSURL) {

        testLoad(imageView, URL: URL)

    }

    func testLoad(imageView: UIImageView, URL: NSURL) {
        imageView.load(URL, placeholder: nil) { URL, image, error in
            println("URL \(URL)")
            println("error \(error)")
        }

    }

}

