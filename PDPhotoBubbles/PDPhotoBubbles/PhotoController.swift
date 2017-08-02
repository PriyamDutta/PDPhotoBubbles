//
//  PhotoController.swift
//  PDPhotoBubbles
//
//  Created by Priyam Dutta on 30/07/17.
//  Copyright © 2017 Priyam Dutta. All rights reserved.
//

import UIKit
import Photos

enum Effect {
    case BubbleEffect
}

class PhotoController: UICollectionViewController {

    private var fetchResults = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
    private var effectType: Effect = .BubbleEffect
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionViewLayout as! BubbleLayout
        layout.isHorizontal = false
        layout.layoutDataSource = (0, 4)
        layout.delegate = self
        effectType = .BubbleEffect
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
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch effectType {
        case .BubbleEffect:
            self.bubbleEffect(cell)
        default:
            break
        }
    }
}

extension PhotoController: BubbleLayoutDelegate{
    
    func collectionView(collectionView: UICollectionView, sizeForItemAt indexPath: NSIndexPath) -> CGSize {
        let random = arc4random_uniform(4) + 2
        return CGSize(width: CGFloat(random * 50), height: CGFloat(random * 30))
    }
}

extension PhotoController {
    
    fileprivate func bubbleEffect(_ cell: UICollectionViewCell) {
        cell.alpha = 0.0
        cell.transform = CGAffineTransform(scaleX: 0.02, y: 0.02)
        UIView.animate(withDuration: 0.35, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            cell.alpha = 1.0
            cell.transform = .identity
        }) { (done) in
        }
    }
}
