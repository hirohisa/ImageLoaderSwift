//
//  RootViewController.swift
//  ImageLoaderSample
//
//  Created by Hirohisa Kawasaki on 2014/10/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        switch indexPath.row {

        case 0:
            cell.textLabel?.text = "Simple"

        case 1:
            cell.textLabel?.text = "Multiple"

        case 2:
            cell.textLabel?.text = "AsyncRender"
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
            viewController = AsyncRenderViewController()

        default:
            break
        }

        if viewController != nil {
            self.navigationController?.pushViewController(viewController!, animated: true)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

}
