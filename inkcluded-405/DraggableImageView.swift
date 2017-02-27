//
//  DraggableImageView.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 2/26/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import UIKit

class DraggableImageView: UIImageView, DraggableElement {

    var isDragging = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureDraggbleGestureRecognizers()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        configureDraggbleGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureDraggbleGestureRecognizers()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        configureDraggbleGestureRecognizers()
    }
    
    func configureDraggbleGestureRecognizers() {
        self.isUserInteractionEnabled = true
        let longTapGR = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(sender:)))
        
        longTapGR.cancelsTouchesInView = false
        longTapGR.minimumPressDuration = 1.5
        
        self.addGestureRecognizer(longTapGR)
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
            isDragging = true
            addShawdow()
        }
        else if (sender.state == .ended) {
            isDragging = false
            removeShadow()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.processTouches(touches: touches, withEvent: event!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches[touches.index(touches.startIndex, offsetBy: 0)]
        let location = touch.location(in: self.superview!)
        
        self.center = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.processTouches(touches: touches, withEvent: event!)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.processTouches(touches: touches, withEvent: event!)
    }
}
