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

    var URLs = [URL]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(SuspendViewController.play))
    }

    func play() {
        toggle(true)
        startLoading()
    }

    func pause() {
        toggle(false)
        pauseLoading()
    }

    func toggle(_ loading: Bool) {
        var buttonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(SuspendViewController.play))

        if loading {
            buttonItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(SuspendViewController.pause))
        }
        navigationItem.rightBarButtonItem = buttonItem
    }


    func startLoading() {
        let start = URLs.count
        for i in start...start+10 {
            let URL = Foundation.URL.imageURL(i)
            ImageLoader.load(URL).completionHandler { completedURL, image, error, cacheType in
                self.insertRow(completedURL)
            }
        }
    }

    func pauseLoading() {
        let end = URLs.count
        for i in end-10...end {
            let URL = Foundation.URL.imageURL(i)
            ImageLoader.suspend(URL)
        }
    }

    func insertRow(_ URL: Foundation.URL) {

        DispatchQueue.main.async(execute: {
            let indexPath = IndexPath(row: self.URLs.count, section: 0)
            self.URLs.append(URL)

            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()

            let state = ImageLoader.state
            if state == .ready {
                self.toggle(false)
            }
        })

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell

        let URL = self.URLs[(indexPath as NSIndexPath).row]
        if let data = Disk.get(URL.absoluteString!.escape()) {
            cell.thumbnailView.image = UIImage(data: data)
        }

        return cell

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return URLs.count
    }

}
