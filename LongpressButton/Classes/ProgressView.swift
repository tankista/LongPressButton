//
//  ProgressView.swift
//  LongpressButton
//
//  Created by Peter Stajger on 09/04/2018.
//  Copyright © 2018 UITouch. All rights reserved.
//

import Foundation
import UIKit

///
/// A simple view that manages animation of progress layer and provides info about current
/// progress.
///
class ProgressView : UIView {
    
    var progress: Double {
        get { return internalProgress }
        set { setProgress(newValue, duration: 0, animated: false) }
    }
    
    /// In case a progress is being animated, this will return actual presentation value
    var currentProgress: Double {
        if let presentationWidth = progressLayer.presentation()?.bounds.size.width {
            return Double(presentationWidth/bounds.width)
        }
        return progress
    }
    
    var progressColor: UIColor? {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressLayer.backgroundColor = progressColor?.cgColor
            CATransaction.commit()
        }
    }
    
    private var internalProgress: Double = 0
    private var progressLayer = CALayer()
    private let animationKey = "animation"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(progressLayer)
        progressLayer.backgroundColor = progressColor?.cgColor
        progressLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressLayer.frame.size.width = bounds.width * CGFloat(progress)
        progressLayer.frame.size.height = bounds.height
    }
    
    func setProgress(_ newValue: Double, duration: TimeInterval, delay: TimeInterval = 0, animated: Bool) {
        let previousProgress = internalProgress
        internalProgress = min(max(0, newValue), 1)
        if animated == true {
            
            progressLayer.removeAnimation(forKey: animationKey)
            
            let fromValue = progressLayer.presentation()?.bounds.size.width ?? 0
            let toValue = bounds.width * CGFloat(internalProgress)
            let animation = CABasicAnimation(keyPath: "bounds.size.width")
            animation.beginTime = CACurrentMediaTime() + delay
            animation.fromValue = fromValue
            animation.toValue = toValue
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            
            // growing animation
            if internalProgress > previousProgress {
                animation.duration = duration
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                progressLayer.add(animation, forKey: animationKey)
            }
            // schrinking animation
            else if internalProgress < previousProgress {
                let diff = TimeInterval(abs(fromValue - toValue)/bounds.width)
                animation.duration = duration * diff
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                progressLayer.add(animation, forKey: animationKey)
            }
        }
        else {
            setNeedsLayout()
        }
    }
    
}
