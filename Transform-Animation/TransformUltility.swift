//
//  TransformUltility.swift
//  Transform-Animation
//
//  Created by dungvh on 3/30/16.
//  Copyright © 2016 dungvh. All rights reserved.
//

import Foundation
import UIKit

protocol Transform {
    
    associatedtype Object
    
    // -- Implement To Custom Run Follow Percent Move
    func transformToPercent(percent:CGFloat)
    
    // -- Implement Run Auto
    func runAnimationAuto()
}

let rangeDuration:CGFloat = 0.01

@IBDesignable
class TransfromView: UIView,Transform {
    typealias Object = UIView
    
    //Scale
    @IBInspectable var minScale:CGFloat = 1
    @IBInspectable var maxScale:CGFloat = 1
    
    //Move
    @IBInspectable var xTranslation:CGFloat = 0
    @IBInspectable var yTranslation:CGFloat = 0
    
    //Rotate
    @IBInspectable var minAngle:CGFloat = 0
    @IBInspectable var maxAngle:CGFloat = 0
    
    // Duration
    @IBInspectable var duration:CGFloat = 0
    
    // View Ultility
    @IBInspectable var maskToBounds:Bool = false{
        didSet{
            self.layer.masksToBounds = maskToBounds
        }
    }
    
    @IBInspectable var cornerRadius:CGFloat = 0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth:CGFloat = 0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor:UIColor = UIColor.whiteColor() {
        didSet{
            self.layer.borderColor = borderColor.CGColor
        }
    }
    
    private var deltaScale:CGFloat {
        return maxScale - minScale
    }
    
    private var deltaAngle:CGFloat{
        return maxAngle - minAngle
    }
    
    private var currentPercent:CGFloat = 0
    private var timer:NSTimer?
    
    // Draw live ---- Designable
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    
    override func awakeFromNib() {
        setup()
    }
    
    // Custom draw in view
    override func drawRect(rect: CGRect) {
        var centerPoint = self.center
        
        centerPoint.x -= xTranslation
        centerPoint.y -= yTranslation
        
        self.center = centerPoint
        
    }
    
    // MARK: --- Memory Management
    deinit{
        print("\(#function) class:\(self.dynamicType)")
        self.timer?.invalidate()
        self.timer = nil
    }
    
    // MARK: --- Handle Percent
    func transformToPercent(percent: CGFloat) {
        self.transform = constructTransform(percent)
        self.alpha = 1 * percent
    }
}

// MARK: --- Run Animation Automatically
extension TransfromView{
    func runAnimationAuto() {
        guard duration > 0 else{
            transformToPercent(1)
            return
        }
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(Double(rangeDuration), target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
    }
    
    
    func runTimer(){
        
        guard  currentPercent < 1 else{
            self.currentPercent = 0
            self.timer?.invalidate()
            self.timer = nil
            return
        }
        
        currentPercent += 1 * rangeDuration / duration
        self.transformToPercent(currentPercent)
    }
}

// MARK: --- Setup Default
private extension TransfromView{
    func setup(){
        self.alpha = 0
        self.transform = constructTransform(0)
    }
    
    func constructTransform(percent:CGFloat) -> CGAffineTransform {
        let scaleTransform = CGAffineTransformMakeScale(minScale + deltaScale * percent, minScale + deltaScale * percent)
        let translateTransform = CGAffineTransformTranslate(scaleTransform, xTranslation * percent, yTranslation * percent)
        let rotateTransform = CGAffineTransformRotate(translateTransform, minAngle + deltaAngle * percent)
        
        return rotateTransform
    }
}