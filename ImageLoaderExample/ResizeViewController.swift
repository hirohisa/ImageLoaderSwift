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

    var timer: Timer?
    func report() {
        let delegate = UIApplication.shared().delegate as! AppDelegate
        delegate.report()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ImageLoader.sharedInstance.automaticallyAdjustsSize = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AppDelegate.report), userInfo: nil, repeats: true)
        RunLoop.main().add(timer!, forMode: RunLoopMode.commonModes)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ImageLoader.sharedInstance.automaticallyAdjustsSize = false
        timer?.invalidate()
        timer = nil
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell

        let imageURL = String.imageURL(indexPath.row)
        cell.imageView.load(imageURL)

        return cell
    }
}
