//
//  TableViewController.swift
//  ImageLoaderExample
//
//  Created by Hirohisa Kawasaki on 10/25/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import ImageLoader

class TableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailView: UIImageView!
}

class TableViewController: UITableViewController {

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell", forIndexPath: indexPath) as! TableViewCell

        let URL = String.imageURL(indexPath.row)
        let placeholder = UIImage(named: "black.jpg")!
        cell.thumbnailView.load(URL, placeholder: placeholder) { URL, image, error, cacheType in
            print("URL \(URL)")
            print("error \(error)")
            print("image \(image?.size), render-image \(cell.thumbnailView.image?.size)")
            print("cacheType \(cacheType.hashValue)")
            if cacheType == CacheType.None {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionFade
                cell.thumbnailView.layer.addAnimation(transition, forKey: nil)
                cell.thumbnailView.image = image
            }
        }

        return cell

    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

}
