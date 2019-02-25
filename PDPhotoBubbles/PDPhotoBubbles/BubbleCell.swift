//
//  BubbleCell.swift
//  PDPhotoBubbles
//
//  Created by Priyam Dutta on 30/07/17.
//  Copyright © 2017 Priyam Dutta. All rights reserved.
//

import UIKit
import Photos

final class BubbleCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width / 2.0
//        self.addMotionEffect(UIMotionEffect.twoAxesTilt(strength: 0.5))
    }
    
    var dataSource: AnyObject! {
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
                        self.transformUI()
                    }
            })
        }
    }
    
    private func transformUI() {
        let scaleAnimate = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimate.fromValue = 1.0
        scaleAnimate.toValue = 1.5
        scaleAnimate.duration = 15.0
        scaleAnimate.beginTime = CFTimeInterval(arc4random_uniform(3))
        scaleAnimate.repeatCount = Float(Int.max)
        scaleAnimate.autoreverses = true
        self.photoImageView.layer.add(scaleAnimate, forKey: "animateScale")
    }
}

extension UIMotionEffect {
    
    class func twoAxesTilt(strength: Float) -> UIMotionEffect {
        // get relative change with `strength` passed to the main method.
        func relativeValue(isMax: Bool, type: UIInterpolatingMotionEffect.EffectType) -> NSValue {
            var transform = CATransform3DIdentity
            transform.m34 = (1.0 * CGFloat(strength)) / 2000.0
            
            let axisValue: CGFloat
            if type == .tiltAlongVerticalAxis {
                // transform vertically
                axisValue = isMax ? -1.0 : 1.0
                transform = CATransform3DRotate(transform, axisValue * CGFloat(Double.pi / 4), 1, 0, 0)
            } else {
                // transform horizontally
                axisValue = isMax ? 1.0 : -1.0
                transform = CATransform3DRotate(transform, axisValue * CGFloat(Double.pi / 4), 0, 1, 0)
            }
            return NSValue(caTransform3D: transform)
        }
        
        // create motion for specified `type`.
        func motion(type: UIInterpolatingMotionEffect.EffectType) -> UIInterpolatingMotionEffect {
            let motion = UIInterpolatingMotionEffect(keyPath: "layer.transform", type: type)
            motion.minimumRelativeValue = relativeValue(isMax: false, type: type)
            motion.maximumRelativeValue = relativeValue(isMax: true, type: type)
            return motion
        }
        
        // create group of horizontal and vertical tilt motions
        let group = UIMotionEffectGroup()
        group.motionEffects = [
            motion(type: .tiltAlongHorizontalAxis),
            motion(type: .tiltAlongVerticalAxis)
        ]
        return group
    }
}

extension UIMotionEffect {
    
    class func twoAxesShift(strength: Float) -> UIMotionEffect {
        // internal method that creates motion effect
        func motion(type: UIInterpolatingMotionEffect.EffectType) -> UIInterpolatingMotionEffect {
            let keyPath = type == .tiltAlongHorizontalAxis ? "center.x" : "center.y"
            let motion = UIInterpolatingMotionEffect(keyPath: keyPath, type: type)
            motion.minimumRelativeValue = -strength
            motion.maximumRelativeValue = strength
            return motion
        }
        
        // group of motion effects
        let group = UIMotionEffectGroup()
        group.motionEffects = [
            motion(type: .tiltAlongHorizontalAxis),
            motion(type: .tiltAlongVerticalAxis)
        ]
        return group
    }
}

