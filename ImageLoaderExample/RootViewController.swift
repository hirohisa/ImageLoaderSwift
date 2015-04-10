//
//  RootViewController.swift
//  ImageLoaderSample
//
//  Created by Hirohisa Kawasaki on 10/24/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        switch indexPath.row {

        case 0:
            cell.textLabel?.text = "Simple"

        case 1:
            cell.textLabel?.text = "Multiple"

        case 2:
            cell.textLabel?.text = "Suspend"

        case 3:
            cell.textLabel?.text = "CollectionView"

        default:
            break
        }

        return cell

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var viewController: UIViewController?

        switch indexPath.row {

        case 0:
            viewController = SimpleViewController()

        case 1:
            viewController = MultipleViewController()

        case 2:
            viewController = SuspendSampleViewController()

        case 3:
            let collectionViewLayout = UICollectionViewFlowLayout()
            collectionViewLayout.itemSize = CGSize(width: view.frame.width/2 - 1, height: 200)
            collectionViewLayout.minimumInteritemSpacing = 1
            viewController = CollectionViewController(collectionViewLayout: collectionViewLayout)

        default:
            break
        }

        if let viewController = viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

}
