//
//  DraggableTextView.swift
//  inkcluded-405
//
//  Created by Nancy on 3/5/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import UIKit

class DraggableTextView: UITextView {
    
    var isDraggingToMove = false
    
    var longTapGR: UILongPressGestureRecognizer!
    
    convenience init() {
        self.init(frame: CGRect.zero, textContainer: nil)
    }
    
    convenience init(frame: CGRect) {
        self.init(frame: frame, textContainer: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureDraggableGestureRecognizers()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor
        
        self.isUserInteractionEnabled = true
        longTapGR = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(sender:)))
        
        longTapGR.cancelsTouchesInView = false
        longTapGR.minimumPressDuration = 1.0
        
        self.addGestureRecognizer(longTapGR)
        
        configureDraggableGestureRecognizers()
    }
    
    func configureDraggableGestureRecognizers() {
        for recognizer:UIGestureRecognizer in self.gestureRecognizers! {
            if (recognizer.isEqual(self.longTapGR)) {
                recognizer.isEnabled = true
            }
            else if (recognizer is UILongPressGestureRecognizer) {
                recognizer.isEnabled = false
            }
        }
    }
    
    func addShawdow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 10
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
    }
    
    func removeShadow() {
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.shadowPath = nil
        layer.shouldRasterize = false
    }
    
    func longTap(sender: UIGestureRecognizer) {
        if (sender.state == .began) {
            isDraggingToMove = true
            addShawdow()
        }
        else if (sender.state == .ended) {
            isDraggingToMove = false
            removeShadow()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isDraggingToMove) {
            let touch = touches[touches.index(touches.startIndex, offsetBy: 0)]
            let location = touch.location(in: self.superview!)
            
            self.center = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }

}
