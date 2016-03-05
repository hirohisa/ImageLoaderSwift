//
//  ResetImageViewController.swift
//  ImageLoaderExample
//
//  Created by Hirohisa Kawasaki on 3/6/16.
//  Copyright © 2016 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import ImageLoader

class ResetImageViewController: CollectionViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIImageView.imageLoader.automaticallyAddTransition = false
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIImageView.imageLoader.automaticallyAddTransition = true
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell

        let imageURL = String.imageURL(indexPath.row)
        cell.imageView.load(imageURL, placeholder: nil) { _, image, _, cacheType in

            if cacheType == CacheType.None {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionFade
                cell.imageView.layer.addAnimation(transition, forKey: nil)
            }

            cell.imageView.image = image
        }

        return cell
    }
}
