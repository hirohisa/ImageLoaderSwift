//
//  SuspendViewController.swift
//  ImageLoaderExample
//
//  Created by Hirohisa Kawasaki on 12/18/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import ImageLoader

class SuspendViewController: UITableViewController {

    var URLs = [NSURL]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: #selector(SuspendViewController.play))
    }

    func play() {
        toggle(true)
        startLoading()
    }

    func pause() {
        toggle(false)
        pauseLoading()
    }

    func toggle(loading: Bool) {
        var buttonItem = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: #selector(SuspendViewController.play))

        if loading {
            buttonItem = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: #selector(SuspendViewController.pause))
        }
        navigationItem.rightBarButtonItem = buttonItem
    }


    func startLoading() {
        let start = URLs.count
        for i in start...start+10 {
            let URL = NSURL.imageURL(i)
            ImageLoader.load(URL).completionHandler { completedURL, image, error, cacheType in
                self.insertRow(completedURL)
            }
        }
    }

    func pauseLoading() {
        let end = URLs.count
        for i in end-10...end {
            let URL = NSURL.imageURL(i)
            ImageLoader.suspend(URL)
        }
    }

    func insertRow(URL: NSURL) {

        dispatch_async(dispatch_get_main_queue(), {
            let indexPath = NSIndexPath(forRow: self.URLs.count, inSection: 0)
            self.URLs.append(URL)

            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.endUpdates()

            let state = ImageLoader.state
            if state == .Ready {
                self.toggle(false)
            }
        })

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell", forIndexPath: indexPath) as! TableViewCell

        let URL = self.URLs[indexPath.row]
        if let data = Disk.get(URL.absoluteString!.escape()) {
            cell.thumbnailView.image = UIImage(data: data)
        }

        return cell

    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return URLs.count
    }

}
