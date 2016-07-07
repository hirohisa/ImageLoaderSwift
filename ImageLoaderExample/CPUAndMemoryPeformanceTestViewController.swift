//
//  CPUAndMemoryPeformanceTestViewController.swift
//  ImageLoaderExample
//
//  Created by Hirohisa Kawasaki on 11/23/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

class CPUAndMemoryPeformanceTestViewController: CollectionViewController {

    var timer: Timer?
    func report() {
        print(#function)
        let delegate = UIApplication.shared().delegate as! AppDelegate
        delegate.report()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CPUAndMemoryPeformanceTestViewController.report), userInfo: nil, repeats: true)
        RunLoop.main().add(timer!, forMode: RunLoopMode.commonModes)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell

        let imageURL = String.imageURL(indexPath.row % 100)

        let startDate = Date()
        cell.imageView.contentMode = contentMode
        cell.imageView.load(imageURL, placeholder: nil) { (URL, _, _, type) -> Void in
            switch type {
            case .none:
                let diff = Date().timeIntervalSince(startDate)
                print("loading time: \(diff)")
                if let image = cell.imageView.image {
                    print("from network, image size: \(image.size)")
                }
            case .cache:
                if let image = cell.imageView.image {
                    print("from cache, image size: \(image.size)")
                }
            }
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 200
    }

}
