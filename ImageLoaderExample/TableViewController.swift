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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell

        let url = String.imageURL((indexPath as NSIndexPath).row)
        let placeholder = UIImage(named: "black.jpg")!
        cell.thumbnailView.load(url, placeholder: placeholder) { url, image, error, cacheType in
            print("url \(url)")
            print("error \(error)")
            print("image \(image?.size), render-image \(cell.thumbnailView.image?.size)")
            print("cacheType \(cacheType.hashValue)")
            if cacheType == CacheType.none {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionFade
                cell.thumbnailView.layer.add(transition, forKey: nil)
                cell.thumbnailView.image = image
            }
        }

        return cell

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

}
