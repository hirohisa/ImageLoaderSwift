//
//  SimpleViewController.swift
//  ImageLoaderSample
//
//  Created by Hirohisa Kawasaki on 2014/10/17.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import ImageLoader

class SimpleViewController: UIViewController {

    var imageView: UIImageView?
    var successURLButton: UIButton?
    var failureURLButton: UIButton?

    let successURL: NSURL = NSURL(string: "http://upload.wikimedia.org/wikipedia/commons/1/1a/Bachalpseeflowers.jpg")!
    let failureURL: NSURL = NSURL(string: "http://upload.wikimedia.org/wikipedia/commons/1/1a/Bachalpseeflowers.jpgg")!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()

        self.configureButtons()
        self.configureImageView()

        self.tryLoadSuccessURL()
    }

    // MARK: - view

    func configureImageView() {

        let imageView: UIImageView = UIImageView()
        imageView.frame = CGRect(
            x: 0,
            y: 0,
            width: 200,
            height: 300
        )
        imageView.center = CGPoint(
            x: CGRectGetWidth(self.view.frame)/2,
            y: CGRectGetHeight(self.view.frame)/2
        )

        self.view.addSubview(imageView)

        self.imageView = imageView

    }

    func configureButtons() {

        let frame: CGRect = CGRect(
            x: 0,
            y: 0,
            width: 100,
            height: 50
        )

        let button1: UIButton = UIButton(frame: frame)
        let button2: UIButton = UIButton(frame: frame)

        button1.setTitle("success", forState: .Normal)
        button1.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button1.setTitleColor(UIColor.greenColor(), forState: .Highlighted)
        button2.setTitle("failure", forState: .Normal)
        button2.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button2.setTitleColor(UIColor.redColor(), forState: .Highlighted)

        button1.center = CGPoint(
            x: 80,
            y: CGRectGetHeight(self.view.frame)/2 + 200
        )
        button2.center = CGPoint(
            x: 240,
            y: CGRectGetHeight(self.view.frame)/2 + 200
        )
        self.view.addSubview(button1)
        self.view.addSubview(button2)

        button1.addTarget(self, action: Selector("tryLoadSuccessURL"), forControlEvents: .TouchUpInside)
        button2.addTarget(self, action: Selector("tryLoadFailureURL"), forControlEvents: .TouchUpInside)

        self.successURLButton = button1
        self.failureURLButton = button2

    }

    // MARK: - try

    func tryLoadSuccessURL() {
        self.tryLoad(self.successURL)
    }

    func tryLoadFailureURL() {
        self.tryLoad(self.failureURL)
    }

    func tryLoad(URL: NSURL) {

        if self.imageView == nil {
            return
        }

        self.testLoad(self.imageView!, URL: URL)

    }

    func testLoad(imageView: UIImageView, URL: NSURL) {
        imageView.load(URL, placeholder: nil) { (_, _, _) -> Void in
            println(__FUNCTION__, "completion")
        }

    }

}

