//
//  CollectionViewController.swift
//  ImageLoaderExample
//
//  Created by Hirohisa Kawasaki on 4/10/15.
//  Copyright (c) 2015 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController {

    class Cell: UICollectionViewCell {
        let imageView = UIImageView(frame: CGRectZero)

        override func layoutSubviews() {
            super.layoutSubviews()
            imageView.frame = contentView.bounds
            contentView.addSubview(imageView)
        }
    }
}

extension CollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.registerClass(Cell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.backgroundColor = UIColor.whiteColor()
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! Cell

        let imageURL = String.imageURL(indexPath.row)
        cell.imageView.load(imageURL)

        return cell
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
}