//
//  MultipleViewController.swift
//  ImageLoaderSample
//
//  Created by Hirohisa Kawasaki on 2014/10/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

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

class MultipleViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let URL: NSURL = NSURL.imageURL(indexPath.row)
        let placeholder: UIImage = UIImage(named: "black.jpg")!
        cell.imageView?.setImage(URL, placeholder: placeholder)

        return cell

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

}
