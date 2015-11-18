//
//  PerfomanceTestViewController.swift
//  ImageLoaderExample
//
//  Created by Hirohisa Kawasaki on 10/25/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

class PerfomanceTestViewController: CollectionViewController {

    var timer: NSTimer?
    func report() {
        print(__FUNCTION__)
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.report()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "report", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
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
