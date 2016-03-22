//
//  BlockingMainThreadPerfomanceTestViewController.swift
//  ImageLoaderExample
//
//  Created by Hirohisa Kawasaki on 11/23/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

class BlockingMainThreadPerfomanceTestViewController: CollectionViewController {

    var watchdog: Watchdog?
    func report() {
        print(#function)
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.report()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        watchdog = Watchdog(threshold: 0.1, handler: { duration in
            print("👮 Main thread was blocked for " + String(format:"%.2f", duration) + "s 👮")
        })
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        watchdog = nil
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell

        let imageURL = String.imageURL(indexPath.row % 100)

        let startDate = NSDate()
        cell.imageView.contentMode = contentMode
        cell.imageView.load(imageURL, placeholder: nil) { (URL, _, _, type) -> Void in
            switch type {
            case .None:
                let diff = NSDate().timeIntervalSinceDate(startDate)
                print("loading time: \(diff)")
                if let image = cell.imageView.image {
                    print("from network, image size: \(image.size)")
                }
            case .Cache:
                if let image = cell.imageView.image {
                    print("from cache, image size: \(image.size)")
                }
            }
        }

        return cell
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 200
    }

}
