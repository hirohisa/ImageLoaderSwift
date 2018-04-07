//
//  CPUAndMemoryPeformanceTestViewController.swift
//  ImageLoaderExample
//
//  Created by Hirohisa Kawasaki on 11/23/15.
//  Copyright © 2015 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import ImageLoader

class CPUAndMemoryPeformanceTestViewController: CollectionViewController {

    var timer: Timer?
    @objc func report() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.report()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Disk().cleanUp()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CPUAndMemoryPeformanceTestViewController.report), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell

        let url = String.imageURL(indexPath.row % 100)

        cell.imageView.contentMode = contentMode
        cell.imageView.image = UIImage(color: UIColor.black)
        cell.imageView.load.request(with: url, options: [.adjustSize])

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 200
    }

}
