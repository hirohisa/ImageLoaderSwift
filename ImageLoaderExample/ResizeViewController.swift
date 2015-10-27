//
//  ResizeViewController.swift
//  ImageLoaderExample
//
//  Created by Hirohisa Kawasaki on 10/25/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import ImageLoader

class ResizeViewController: CollectionViewController {

    var timer: NSTimer?
    func report() {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.report()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ImageLoader.sharedInstance.automaticallyAdjustsSize = true
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "report", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        ImageLoader.sharedInstance.automaticallyAdjustsSize = false
        timer?.invalidate()
        timer = nil
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell

        let imageURL = String.imageURL(indexPath.row)
        cell.imageView.load(imageURL)

        return cell
    }
}
