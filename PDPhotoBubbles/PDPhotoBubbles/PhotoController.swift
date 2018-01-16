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
    case SoothTranslateEffect
}

class PhotoController: UICollectionViewController {

    private var fetchResults = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
    fileprivate var configure:(Effect, isHorizontal: Bool)! = (.BubbleEffect, true)
    fileprivate var currentOffset:CGFloat = 0.0
    fileprivate var visibleBubbles: [UICollectionViewCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure = (.SoothTranslateEffect, false)
        let layout = collectionViewLayout as! BubbleLayout
        layout.isHorizontal = configure.1
        layout.layoutDataSource = (0, 4)
        layout.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView!.reloadData()
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
        switch configure.0 {
        case .BubbleEffect:
            self.bubbleEffect(cell)
        case .SoothTranslateEffect:
            self.soothTranslateEffect(cell)
        }
    }
    
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if configure.1 {
            currentOffset = collectionView!.contentOffset.x
        }else{
            currentOffset = collectionView!.contentOffset.y
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        visibleBubbles = collectionView.visibleCells
        let selectedBubble = collectionView.cellForItem(at: indexPath)
        scatterEffect(visibleBubbles, selectedBubble: selectedBubble!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.23) {
            self.transitionToDetail(indexPath.item)
        }
    }
    
    fileprivate func transitionToDetail(_ index: Int) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoDetailController") as! PhotoDetailController
        detailVC.view.backgroundColor = .clear
        detailVC.view.alpha = 1.0
        detailVC.modalPresentationStyle = .overCurrentContext
        detailVC.phasset = fetchResults[index]
        detailVC.dismissCosure = { [weak self] in
            for item in (self?.visibleBubbles)! {
                let random:CGFloat = CGFloat(arc4random_uniform(4)) / 10
                UIView.animate(withDuration: 1.5, delay: TimeInterval(random), options: .curveEaseInOut, animations: {
                   item.transform = .identity
                }, completion: nil)
            }
        }
        self.present(detailVC, animated: false) {
        }
    }
}

extension PhotoController: BubbleLayoutDelegate{
    
    func collectionView(collectionView: UICollectionView, sizeForItemAt indexPath: NSIndexPath) -> CGSize {
        let random = arc4random_uniform(4) + 2
        return CGSize(width: CGFloat(random * 50), height: CGFloat(random * 30))
    }
}

typealias EffectsOperation = PhotoController
extension EffectsOperation {
    
    //MARK:- Bubble Displaying Effect
    fileprivate func bubbleEffect(_ cell: UICollectionViewCell) {
        cell.alpha = 0.0
        cell.transform = CGAffineTransform(scaleX: 0.02, y: 0.02)
        UIView.animate(withDuration: 0.35, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            cell.alpha = 1.0
            cell.transform = .identity
        }) { (done) in
        }
    }
    
    fileprivate func soothTranslateEffect(_ cell: UICollectionViewCell) {
        var translation:CGFloat = 100
        if configure.1 {
            translation = currentOffset <= collectionView!.contentOffset.x ? 100 : -100
        }else{
            translation = currentOffset <= collectionView!.contentOffset.y ? 100 : -100
        }
        cell.transform = configure.1 ? CGAffineTransform(translationX: translation, y: 0.0) : CGAffineTransform(translationX: 0.0, y: translation)
        UIView.animate(withDuration: 0.45, delay: 0.0, options: .curveEaseInOut, animations: {
            cell.transform = .identity
        }) { (done) in
        }
    }
    
    //MARK:- Bubble Selection effect
    fileprivate func scatterEffect(_ visibleBubbles: [UICollectionViewCell], selectedBubble: UICollectionViewCell) {
        
        for item in visibleBubbles {
            if item != selectedBubble {
                let random:CGFloat = CGFloat(arc4random_uniform(4)) / 10
//                debugPrint("random: \(random)")
                UIView.animate(withDuration: 2.0, delay: TimeInterval(random), options: .curveEaseInOut, animations: {
                    switch self.getQuadrant(item.center) {
                    case 1:
                        item.transform = CGAffineTransform(translationX: -1000, y: -1000)
                    case 2:
                        item.transform = CGAffineTransform(translationX: 1000, y: -1000)
                    case 3:
                        item.transform = CGAffineTransform(translationX: -1000, y: 1000)
                    case 4:
                        item.transform = CGAffineTransform(translationX: 1000, y: 1000)
                    default:
                        break
                    }
                }, completion: { (done) in
                    
                })
            }else{
                UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: { 
//                    item.center = self.view.center
                }, completion: { (done) in
                })
            }
        }
    }
    
    private func getQuadrant(_ point: CGPoint) -> Int {
        
        if point.x <= self.view.frame.midX && point.y <= self.view.frame.midY {
            return 1
        }
        if point.x > self.view.frame.midX && point.y <= self.view.frame.midY {
            return 2
        }
        if point.x <= self.view.frame.midX && point.y > self.view.frame.midY {
            return 3
        }
        if point.x > self.view.frame.midX && point.y > self.view.frame.midY {
            return 4
        }
        return 1
    }
    
}




























