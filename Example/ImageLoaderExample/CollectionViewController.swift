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

    var contentMode: UIView.ContentMode = UIView.ContentMode.scaleToFill {
        didSet {
            reloadData()
        }
    }

    let modeMap: [UIView.ContentMode: UIView.ContentMode] = [
        .scaleToFill: .scaleAspectFit,
        .scaleAspectFit: .scaleAspectFill,
        .scaleAspectFill: .scaleToFill,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change", style: .plain, target: self, action: #selector(CollectionViewController.changeContentMode))
        reloadData()
    }

    @objc func changeContentMode() {
        contentMode = modeMap[contentMode]!
    }

    func reloadData() {
        switch contentMode {
        case .scaleToFill:
            title = "ScaleToFill"
        case .scaleAspectFit:
            title = "ScaleAspectFit"
        case .scaleAspectFill:
            title = "ScaleAspectFill"
        default:
            break
        }

        collectionView?.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell

        let url = String.imageURL(indexPath.row)
        cell.imageView.contentMode = contentMode
        cell.imageView.load.request(with: url)

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
