//  https://github.com/swtlovewtt/WTKit
//  CustomExtension.swift
//  WTKit
//
//  Created by SongWentong on 5/26/16.
//  Copyright © 2016 SongWentong. All rights reserved.
//
#if os(iOS)
import Foundation
import UIKit
import CoreGraphics
    
private let UIViewControllerWTKitDefaultLoadingTextKey = "UIViewControllerWTKitDefaultLoadingTextKey"
extension UIViewController{
    
    /*!
        提示文字
     */
    public func showHudWithTip(_ tip:String){
         WTTipView.showTip(tip as NSString)
    }
    /*!
        显示loading指示器(activity indicator)
     */
    public func showLoadingView(){
        _ = WTHudView.showHudInView(self.view, animatied: true)
    }
    /*!
        隐藏loading指示器
     */
    public func hideLoadingView(){
        WTHudView.hideHudInView(self.view, animatied: true)
    }
    
    /*!
        可以用于设置默认的loading的文字
     */
    public class func setDefaultLoadingText(_ string:String){
        UserDefaults.standard.set(string, forKey: UIViewControllerWTKitDefaultLoadingTextKey)
    }
    /*!
        获取默认的loading文字
     */
    public class func defaultLoadingText()->String{
        var text:String? = UserDefaults.standard.string(forKey: UIViewControllerWTKitDefaultLoadingTextKey)
        if text == nil {
            text = "Loading..."
        }
        return text!
    }
}

extension UIView
{
    var width:      CGFloat { return self.frame.size.width }
    var height:     CGFloat { return self.frame.size.height }
    var size:       CGSize  { return self.frame.size}
    
    var origin:     CGPoint { return self.frame.origin }
    var x:          CGFloat { return self.frame.origin.x }
    var y:          CGFloat { return self.frame.origin.y }
    var centerX:    CGFloat { return self.center.x }
    var centerY:    CGFloat { return self.center.y }
    
    var left:       CGFloat { return self.frame.origin.x }
    var right:      CGFloat { return self.frame.origin.x + self.frame.size.width }
    var top:        CGFloat { return self.frame.origin.y }
    var bottom:     CGFloat { return self.frame.origin.y + self.frame.size.height }
    
    func setWidth(_ width:CGFloat) {
        self.frame.size.width = width
    }
    
    func setHeight(_ height:CGFloat) {
        self.frame.size.height = height
    }
    
    func setSize(_ size:CGSize) {
        self.frame.size = size
    }
    
    func setOrigin(_ point:CGPoint) {
        self.frame.origin = point
    }
    
    func setX(_ x:CGFloat) {
        self.frame.origin = CGPoint(x: x, y: self.frame.origin.y)
    }
    
    func setY(_ y:CGFloat) {
        self.frame.origin = CGPoint(x: self.frame.origin.x, y: y)
    }
    
    func setCenterX(_ x:CGFloat) {
        self.center = CGPoint(x: x, y: self.center.y)
    }
    
    func setCenterY(_ y:CGFloat) {
        self.center = CGPoint(x: self.center.x, y: y)
    }
    
    func roundCorner(_ radius:CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func setTop(_ top:CGFloat) {
        self.frame.origin.y = top
    }
    
    func setLeft(_ left:CGFloat) {
        self.frame.origin.x = left
    }
    
    func setRight(_ right:CGFloat) {
        self.frame.origin.x = right - self.frame.size.width
    }
    
    func setBottom(_ bottom:CGFloat) {
        self.frame.origin.y = bottom - self.frame.size.height
    }
    

    
}

#endif
