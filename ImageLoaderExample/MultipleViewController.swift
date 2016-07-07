//
//  MultipleViewController.swift
//  ImageLoaderSample
//
//  Created by Hirohisa Kawasaki on 10/24/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import ImageLoader

class MultipleViewController: UITableViewController {

    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    }

    func reportMemory() {
        let delegate = UIApplication.shared().delegate as! AppDelegate
        delegate.reportMemory()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MultipleViewController.reportMemory), userInfo: nil, repeats: true)
        RunLoop.main().add(timer!, forMode: RunLoopMode.commonModes)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let url = String.imageURL(indexPath.row)
        let placeholder = UIImage(named: "black.jpg")!
        cell.imageView?.load(url, placeholder: placeholder) { url, image, error, cacheType in
            print("url \(url)")
            print("error \(error)")
            print("view's size \(cell.imageView?.frame.size), image's size \(cell.imageView?.image?.size)")
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
