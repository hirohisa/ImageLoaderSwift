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
        cell.imageView.load(imageURL)

        return cell
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 200
    }

}
