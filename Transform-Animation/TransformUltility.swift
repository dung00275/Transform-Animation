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
    func runAnimationAuto(completion:(()->())?)
}

let rangeDuration:CGFloat = 0.01

@IBDesignable
class TransfromView: UIView,Transform {
    typealias Object = UIView
    
    private var completionAuto:(()->())?
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
    
    @IBInspectable var AnimationScale:Int = 0
    @IBInspectable var AnimationTranslate:Int = 0
    @IBInspectable var AnimationRotate:Int = 0
    
    // Begin
    @IBInspectable var BeginScale:CGFloat = 0
    @IBInspectable var BeginTranslation:CGFloat = 0
    @IBInspectable var BeginRotate:CGFloat = 0
    
    // End
    @IBInspectable var EndScale:CGFloat = 0
    @IBInspectable var EndTranslation:CGFloat = 0
    @IBInspectable var EndRotate:CGFloat = 0
    
    
    private var deltaScale:CGFloat {
        return maxScale - minScale
    }
    
    private var deltaAngle:CGFloat{
        return maxAngle - minAngle
    }
    
    private var currentPercent:CGFloat = 0
    private var timer:NSTimer?

    
    private var currentScale:CGFloat = 0
    
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
        print("first center : \(self.center)")
    }
    
    // MARK: --- Memory Management
    deinit{
        print("\(#function) class:\(self.dynamicType)")
        self.timer?.invalidate()
        self.timer = nil
        self.completionAuto = nil
    }
    
    // MARK: --- Custom Transform 
    func transformScale(percent:CGFloat) -> CGAffineTransform {
        
        let transform = self.transform
        let rotation = Float(atan2(Double(transform.b), Double(transform.a)))
        
        let translationTransform = CGAffineTransformMakeTranslation(transform.tx, transform.ty)
        let rotnTransform = CGAffineTransformRotate(translationTransform,CGFloat(rotation))
        currentScale = minScale + deltaScale * percent
        let scaleTransform = CGAffineTransformScale(rotnTransform,currentScale,currentScale)
        
        
        return scaleTransform
    }
    
    func transformTranslate(percent:CGFloat) -> CGAffineTransform {
        
        var transform = self.transform
        
        transform.tx = xTranslation * percent
        transform.ty = yTranslation * percent
        
        return transform
    }
    
    func transformRotate(percent:CGFloat) -> CGAffineTransform {
        let transform = self.transform
        let translationTransform = CGAffineTransformMakeTranslation(transform.tx, transform.ty)
        let scaleTransform = CGAffineTransformScale(translationTransform, currentScale, currentScale)
        
        return CGAffineTransformRotate(scaleTransform,minAngle + deltaAngle * percent)
    }
    
    func checkAnimation(index:Int,percent:CGFloat) -> (Int,CGAffineTransform)? {
        
        switch index {
        case AnimationScale:
             print("//////Index : \(index)  Scale //////")
            let range = BeginScale...EndScale
            return range ~= percent ? (index,transformScale((percent - BeginScale) / (EndScale - BeginScale))) : nil
        case AnimationTranslate:
            print("////// Index : \(index) Translate //////")
            let range = BeginTranslation...EndTranslation
            return range ~= percent ? (index,transformTranslate((percent - BeginTranslation) / (EndScale - BeginTranslation))) : nil
        case AnimationRotate:
            print("////// Index : \(index) Rotate //////")
            let range = BeginRotate...EndRotate
            return range ~= percent ? (index,transformRotate((percent - BeginRotate) / (EndRotate - BeginRotate) )) : nil
        default:
            break
        }
        
        return nil
    }
    
    
    
    // MARK: --- Handle Percent
    func transformToPercent(percent: CGFloat) {
        //self.alpha = 1 * percent
        print(" current percent :\(percent * 100) %")
        defer{
            currentPercent = percent
        }
        if  EndRotate == EndTranslation && EndTranslation == EndScale {
            self.transform = constructTransform(percent)
        }else
        {
            if let value = checkAnimation(1, percent: percent)
            {
                self.transform = value.1
            }
            else if let value = checkAnimation(2, percent: percent)
            {
                self.transform = value.1
            }
            
            else if let value = checkAnimation(3, percent: percent)
            {
                self.transform = value.1
            }
        }
    }
}

// MARK: --- Run Animation Automatically
extension TransfromView{
    func runAnimationAuto(completion:(()->())?) {
        self.completionAuto = completion
        self.currentPercent = 0
        guard duration > 0 else{
            transformToPercent(1)
            return
        }
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(Double(rangeDuration), target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
    }
    
    
    func runTimer(){
        
        guard  currentPercent < 1 else{
            self.timer?.invalidate()
            self.timer = nil
            completionAuto?()
            return
        }
        
        currentPercent += 1 * rangeDuration / duration
        self.transformToPercent(currentPercent)
    }
}

// MARK: --- Setup Default
private extension TransfromView{
    func setup(){
        self.currentScale = minScale
        self.transform = constructTransform(0)
    }
    
    func constructTransform(percent:CGFloat) -> CGAffineTransform {
        let scaleTransform = CGAffineTransformMakeScale(minScale + deltaScale * percent, minScale + deltaScale * percent)
        let translateTransform = CGAffineTransformTranslate(scaleTransform, xTranslation * percent, yTranslation * percent)
        let rotateTransform = CGAffineTransformRotate(translateTransform, minAngle + deltaAngle * percent)
        
        return rotateTransform
    }
}

// MARK: ---- Object Call All Animation In View

class CollectAnimationWorker:Transform
{
    typealias Object = [TransfromView]
    
    var arrayViewAnimation:Object
    var duration:CGFloat
    private var timer:NSTimer?
    
    private var completionAuto:(()->())?
    init(arrayViewTransform:Object)
    {
        self.arrayViewAnimation = arrayViewTransform
        duration = 0
        for view in self.arrayViewAnimation {
            duration = max(duration, view.duration)
        }
        
    }
    
    func transformToPercent(percent: CGFloat) {
        for view in self.arrayViewAnimation {
            view.transformToPercent(percent)
        }
    }
    func runAnimationAuto(completion: (() -> ())?) {
        completionAuto = completion
        for view in self.arrayViewAnimation {
            view.runAnimationAuto(nil)
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(Double(duration), target: self, selector: #selector(runtimer), userInfo: nil, repeats: false)
    }
    
    @objc func runtimer(){
        self.timer?.invalidate()
        self.timer = nil
    }
    
    deinit{
        print("\(#function) class:\(self.dynamicType)")
        self.timer?.invalidate()
        self.timer = nil
        self.completionAuto = nil
    }
    
    
}

