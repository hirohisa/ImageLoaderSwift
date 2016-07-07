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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIImageView.imageLoader.automaticallySetImage = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIImageView.imageLoader.automaticallySetImage = true
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell

        let imageURL = String.imageURL((indexPath as NSIndexPath).row)
        cell.imageView.load(imageURL, placeholder: nil) { _, image, _, cacheType in
            if cacheType == CacheType.none {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionFade
                cell.imageView.layer.add(transition, forKey: nil)
            }

            cell.imageView.image = image
        }

        return cell
    }
}
