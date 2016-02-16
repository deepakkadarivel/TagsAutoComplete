//
//  CustomSearchBar.swift
//  CustomSearchBar
//
//  Created by Deepak Kadarivel on 15/02/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

class CustomSearchBar: UISearchBar {

    var preferredFont: UIFont!
    var preferredTextColor: UIColor!
    
    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)
        self.frame = frame
        self.preferredFont = font
        self.preferredTextColor = textColor
        
        searchBarStyle = UISearchBarStyle.Prominent
        translucent = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func indexOfSearchFieldInSubViews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0] as UIView
        
        for var i = 0; i < searchBarView.subviews.count; ++i {
            if searchBarView.subviews[i].isKindOfClass(UITextField) {
                index = i
                break
            }
        }
        
        return index
    }

    override func drawRect(rect: CGRect) {
        if let index = indexOfSearchFieldInSubViews() {
            let searchField: UITextField = (subviews[0] as UIView).subviews[index] as! UITextField
            
            searchField.frame = CGRectMake(5.0, 5.0, frame.size.width, frame.size.height)
            
            searchField.font = preferredFont
            searchField.textColor = preferredTextColor
            
            searchField.backgroundColor = barTintColor
        }
        
        let startPoint = CGPointMake(0.0, frame.size.height)
        let endPoint = CGPointMake(frame.size.width
            , frame.size.height)
        
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        path.addLineToPoint(endPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = preferredTextColor.CGColor
        shapeLayer.lineWidth = 2.5
        
        layer.addSublayer(shapeLayer)
        
        super.drawRect(rect)
    }
}
