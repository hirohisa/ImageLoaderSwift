//
//  CollectionViewController.swift
//  ImageLoaderExample
//
//  Created by Hirohisa Kawasaki on 4/10/15.
//  Copyright (c) 2015 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

class CollectionViewController: UICollectionViewController {

    var contentMode: UIViewContentMode = UIViewContentMode.ScaleToFill {
        didSet {
            reloadData()
        }
    }

    let modeMap: [UIViewContentMode: UIViewContentMode] = [
        .ScaleToFill: .ScaleAspectFit,
        .ScaleAspectFit: .ScaleAspectFill,
        .ScaleAspectFill: .ScaleToFill,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change", style: .Plain, target: self, action: #selector(CollectionViewController.changeContentMode))
        reloadData()
    }

    func changeContentMode() {
        contentMode = modeMap[contentMode]!
    }

    func reloadData() {
        switch contentMode {
        case .ScaleToFill:
            title = "ScaleToFill"
        case .ScaleAspectFit:
            title = "ScaleAspectFit"
        case .ScaleAspectFill:
            title = "ScaleAspectFill"
        default:
            break
        }

        collectionView?.reloadData()
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell

        let imageURL = String.imageURL(indexPath.row)
        cell.imageView.contentMode = contentMode
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