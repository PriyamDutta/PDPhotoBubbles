//
//  BubbleLayout.swift
//  PDPhotoBubbles
//
//  Created by Priyam Dutta on 30/07/17.
//  Copyright © 2017 Priyam Dutta. All rights reserved.
//

import UIKit

protocol BubbleLayoutDelegate: class {
    func collectionView(collectionView: UICollectionView, sizeForItemAt indexPath: NSIndexPath) -> CGSize
}

final class BubbleLayout: UICollectionViewLayout {
    
    weak var delegate: BubbleLayoutDelegate?
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
        guard cache.isEmpty else { return }
        guard layoutDataSource.rowsOrColumns != 0 else { return }
        
        layoutDataSource.section = 0
        isHorizontal ? prepareHorizontalLayout() : prepareVerticalLayout()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        layoutAttributes.reserveCapacity(cache.count)
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
        for item in 0..<collectionView!.numberOfItems(inSection: layoutDataSource.section) {
            
            let indexPath = NSIndexPath(item: item, section: layoutDataSource.section)
            if let attrWidth = delegate?.collectionView(collectionView: collectionView!, sizeForItemAt: indexPath).width {
                let attrFrame = CGRect(x: xOffsets[row], y: yOffsets[row], width: attrWidth - padding, height: attrWidth - padding)
                let attributes = UICollectionViewLayoutAttributes(forCellWith:indexPath as IndexPath)
                attributes.frame = attrFrame
                cache.append(attributes)
                contentWidth = max(contentWidth, attrFrame.maxX)
                xOffsets[row] = xOffsets[row] + attrWidth
                row = row >= (layoutDataSource.rowsOrColumns - 1) ? 0 : (row + 1)
//                debugPrint("Row: \(row), xOffset: \(xOffsets[row]), yOffset: \(yOffsets[row])")
            }
        }
    }
    
    private func prepareVerticalLayout() {
        
        let rowHeight = layoutLength / CGFloat(layoutDataSource.rowsOrColumns)
        var xOffsets: [CGFloat] = []
        var yOffsets = [CGFloat](repeating: 0, count: layoutDataSource.rowsOrColumns)
        for column in 0..<layoutDataSource.rowsOrColumns {
            xOffsets.append(CGFloat(column) * rowHeight)
        }
        var column = 0
        for item in 0..<collectionView!.numberOfItems(inSection: layoutDataSource.section) {
            
            let indexPath = NSIndexPath(item: item, section: layoutDataSource.section)
            if let attrHeight = delegate?.collectionView(collectionView: collectionView!, sizeForItemAt: indexPath).height {
                let attrFrame = CGRect(x: xOffsets[column], y: yOffsets[column], width: attrHeight - padding, height: attrHeight - padding)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
                attributes.frame = attrFrame
//                debugPrint("Column: \(column), xOffset: \(xOffsets[column]), yOffset: \(yOffsets[column])")
                cache.append(attributes)
                contentHeight = max(contentHeight, attrFrame.maxY)
                yOffsets[column] = yOffsets[column] + attrHeight
                column = column >= (layoutDataSource.rowsOrColumns - 1) ? 0 : (column + 1)
            }
        }
    }
}
























