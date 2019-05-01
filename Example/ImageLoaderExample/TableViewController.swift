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

        let url = String.imageURL(indexPath.row)
        cell.thumbnailView.image = UIImage(named: "black.jpg")
        cell.thumbnailView.load.request(with: url, onCompletion: { image, error, operation in
            print("image \(String(describing: image?.size)), render-image \(String(describing: cell.thumbnailView.image?.size))")
            if operation == .network {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = CATransitionType.fade
                cell.thumbnailView.layer.add(transition, forKey: nil)
                cell.thumbnailView.image = image
            }
        })

        return cell

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

}
