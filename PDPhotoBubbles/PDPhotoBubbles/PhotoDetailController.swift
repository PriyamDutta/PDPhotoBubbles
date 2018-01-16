//
//  PhotoDetailController.swift
//  PDPhotoBubbles
//
//  Created by Priyam Dutta on 05/08/17.
//  Copyright © 2017 Priyam Dutta. All rights reserved.
//

import UIKit
import Photos

class PhotoDetailController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    var phasset:PHAsset!
    var dismissCosure: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setImage(phasset)
        
        self.detailImageView.clipsToBounds = true
        self.detailImageView.isUserInteractionEnabled = true
        self.detailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissView)))
        self.transformImageView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissCosure?()
    }
    
    private func setImage(_ asset: PHAsset?) {
        guard (asset != nil) else {
            return
        }
        let imageOptions = PHImageRequestOptions()
        imageOptions.version = .current
        PHImageManager.default().requestImage(
            for: asset!,
            targetSize: detailImageView.bounds.size,
            contentMode: .aspectFit,
            options: imageOptions,
            resultHandler: { image, _ in
                DispatchQueue.main.async {
                    self.setImageViewExtent(image!)
                }
        })
    }
    
    private func setImageViewExtent(_ image: UIImage) {
        self.detailImageView.image = image//resizeImage(image: image, targetSize: self.detailImageView.frame.size)
//        self.detailImageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        self.detailImageView.center = self.view.center
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * heightRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    private func transformImageView() {
        let animateCorner = CABasicAnimation(keyPath: "cornerRadius")
        animateCorner.fromValue = self.detailImageView.frame.width / 2.0
        animateCorner.toValue = 0
        animateCorner.duration = 0.35
        animateCorner.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animateCorner.fillMode = kCAFillModeBackwards
        self.detailImageView.layer.add(animateCorner, forKey: "cornerAnimate")
        
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true) {
        }
    }

}
