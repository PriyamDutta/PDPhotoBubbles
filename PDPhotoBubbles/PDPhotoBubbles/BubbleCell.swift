//
//  BubbleCell.swift
//  PDPhotoBubbles
//
//  Created by Priyam Dutta on 30/07/17.
//  Copyright © 2017 Priyam Dutta. All rights reserved.
//

import UIKit
import Photos

class BubbleCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width / 2.0
    }
    
    var dataSource: AnyObject!{
        didSet{
            let imageOptions = PHImageRequestOptions()
            imageOptions.version = .current
            
            PHImageManager.default().requestImage(
                for: dataSource as! PHAsset,
                targetSize: photoImageView.bounds.size,
                contentMode: .aspectFill,
                options: imageOptions,
                resultHandler: { image, _ in
                    
                    DispatchQueue.main.async {
                        self.photoImageView.image = image
                    }
            })
        }
    }
    
    
}
