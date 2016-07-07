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

    var urls = [URL]()

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
        let start = urls.count
        for i in start...start+10 {
            let url = URL.imageURL(i)
            let _ = ImageLoader.load(url).completionHandler { completedURL, _, _, _ in
                self.insertRow(completedURL)
            }
        }
    }

    func pauseLoading() {
        let end = urls.count
        for i in end-10...end {
            let url = URL.imageURL(i)
            let _ = ImageLoader.suspend(url)
        }
    }

    func insertRow(_ url: URL) {

        DispatchQueue.main.async(execute: {
            let indexPath = IndexPath(row: self.urls.count, section: 0)
            self.urls.append(url)

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

        let url = self.urls[indexPath.row]
        if let str = url.absoluteString!.escape(), data = Disk.get(str) {
            cell.thumbnailView.image = UIImage(data: data)
        }

        return cell

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urls.count
    }

}
