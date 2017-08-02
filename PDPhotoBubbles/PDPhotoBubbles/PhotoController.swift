//
//  PhotoController.swift
//  PDPhotoBubbles
//
//  Created by Priyam Dutta on 30/07/17.
//  Copyright © 2017 Priyam Dutta. All rights reserved.
//

import UIKit
import Photos

class PhotoController: UICollectionViewController {

    private var fetchResults = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionViewLayout as! BubbleLayout
        layout.isHorizontal = true
        layout.layoutDataSource = (0, 4)
        layout.delegate = self
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BubbleCell", for: indexPath) as! BubbleCell
        cell.dataSource = fetchResults[indexPath.item]
        return cell
    }
}

extension PhotoController: BubbleLayoutDelegate{
    
    func collectionView(collectionView: UICollectionView, sizeForItemAt indexPath: NSIndexPath) -> CGSize {
        let random = arc4random_uniform(4) + 2
        return CGSize(width: CGFloat(random * 50), height: 100)
    }

}
