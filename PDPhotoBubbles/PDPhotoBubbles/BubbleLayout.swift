//
//  BubbleLayout.swift
//  PDPhotoBubbles
//
//  Created by Priyam Dutta on 30/07/17.
//  Copyright © 2017 Priyam Dutta. All rights reserved.
//

import UIKit

protocol BubbleLayoutDelegate {
    func collectionView(collectionView: UICollectionView, sizeForItemAt indexPath: NSIndexPath) -> CGSize
}

class BubbleLayout: UICollectionViewLayout {
    
    var delegate: BubbleLayoutDelegate!
    var layoutDataSource:(section: Int, rowsOrColumns: Int)!
    var isHorizontal = true
    
    private var contentWidth:CGFloat = 0
    private var contentHeight:CGFloat = 0
    private let padding:CGFloat = 10
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var layoutLength: CGFloat {
        get {
            return isHorizontal ? collectionView!.bounds.height : collectionView!.bounds.width
        }
    }
    
    override var collectionViewContentSize: CGSize{
        return isHorizontal ? CGSize(width: contentWidth, height: layoutLength) : CGSize(width: layoutLength, height: contentHeight)
    }
    
    override func prepare() {
        guard cache.isEmpty else {
            return
        }
        
        guard layoutDataSource.rowsOrColumns != 0 else {
            return
        }
        
        layoutDataSource.0 = 0
        isHorizontal ? prepareHorizontalLayout() : prepareVerticalLayout()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    private func prepareHorizontalLayout() {
        
        let rowWidth = layoutLength / CGFloat(layoutDataSource.rowsOrColumns)
       
        var xOffsets = [CGFloat](repeating: 0, count: layoutDataSource.rowsOrColumns)
        var yOffsets:[CGFloat] = []
        
        for row in 0..<layoutDataSource.rowsOrColumns {
            yOffsets.append(CGFloat(row) * rowWidth)
        }
        
        var row = 0
        for item in 0..<collectionView!.numberOfItems(inSection: layoutDataSource.0) {
            
            let indexPath = NSIndexPath(item: item, section: layoutDataSource.0)
            let attrWidth = delegate.collectionView(collectionView: collectionView!, sizeForItemAt: indexPath).width
            
            let attrFrame = CGRect(x: xOffsets[row], y: yOffsets[row], width: attrWidth - padding, height: attrWidth - padding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith:indexPath as IndexPath)
            attributes.frame = attrFrame
            
            debugPrint("Row: \(row), xOffset: \(xOffsets[row]), yOffset: \(yOffsets[row])")
            
            cache.append(attributes)
            contentWidth = max(contentWidth, attrFrame.maxX)
            
            xOffsets[row] = xOffsets[row] + attrWidth
            row = row >= (layoutDataSource.1 - 1) ? 0 : 1
        }
        
    }
    
    private func prepareVerticalLayout() {
        
    }
    
}
