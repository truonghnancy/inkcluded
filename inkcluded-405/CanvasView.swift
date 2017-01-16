//
//  CanvasView.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/13/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

class CanvasView: UIView {
    var controller: CanvasViewController?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            controller?.startCurrentLine(point: currentPoint)
        }
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            controller?.addPointToCurrentLine(point: currentPoint)
        }
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            controller?.addLastPointToCurrentLine(point: currentPoint)
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let paths = controller?.getAllPaths()
        
        for path in paths! {
            path.stroke()
        }
    }
    
}
