//
//  BlockingMainThreadPerfomanceTestViewController.swift
//  ImageLoaderExample
//
//  Created by Hirohisa Kawasaki on 11/23/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import ImageLoader

class BlockingMainThreadPerfomanceTestViewController: CollectionViewController {

    var watchdog: Watchdog?
    func report() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.report()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Disk().cleanUp()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        watchdog = Watchdog(threshold: 0.1, handler: { duration in
            print("👮 Main thread was blocked for " + String(format:"%.2f", duration) + "s 👮")
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        watchdog = nil
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell

        let url = String.imageURL(indexPath.row % 100)

        let startDate = Date()
        cell.imageView.contentMode = contentMode
        cell.imageView.image = UIImage(color: UIColor.black)
        cell.imageView.load.request(with: url, onCompletion: { _, _, operation in
            switch operation {
            case .network:
                let diff = Date().timeIntervalSince(startDate)
                print("loading time: \(diff)")
                if let image = cell.imageView.image {
                    print("from network, image size: \(image.size)")
                }
            case .disk:
                if let image = cell.imageView.image {
                    print("from cache, image size: \(image.size)")
                }

            case .error:
                print("error")
            }
        })

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 200
    }

}
