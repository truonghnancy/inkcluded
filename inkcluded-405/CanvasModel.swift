//
//  CanvasModel.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/13/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

class CanvasModel {
    private var currentBezierPath: UIBezierPath?
    private var paths: [UIBezierPath]?
    
    init() {
        self.paths = [UIBezierPath]()
    }
    
    func getAllPaths() -> [UIBezierPath] {
        if let path = currentBezierPath {
            return self.paths! + [path]
        }
        return self.paths!
    }
    
    func startCurrentLine(point: CGPoint) {
        currentBezierPath = UIBezierPath()
        currentBezierPath?.move(to: point)
        currentBezierPath?.addLine(to: point)
    }
    
    func addPointToCurrentLine(point: CGPoint) {
        currentBezierPath?.addLine(to: point)
    }
    
    func addLastPointToCurrentLine(point: CGPoint) {
        currentBezierPath?.addLine(to: point)
        self.paths?.append(currentBezierPath!)
        currentBezierPath = nil
    }
}
