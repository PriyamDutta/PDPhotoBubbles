//
//  BubbleCell.swift
//  PDPhotoBubbles
//
//  Created by Priyam Dutta on 30/07/17.
//  Copyright © 2017 Priyam Dutta. All rights reserved.
//

import UIKit

class BubbleCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var dataSource: AnyObject!{
        didSet{
            
        }
    }
    
    
}
