//
//  CanvasViewController.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/13/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

class CanvasViewController: UIViewController {
    @IBOutlet var canvasView: CanvasView!
    private var model: CanvasModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = CanvasModel()
        canvasView.controller = self
    }
    
    func startCurrentLine(point: CGPoint) {
        model?.startCurrentLine(point: point)
    }
    
    func addPointToCurrentLine(point: CGPoint) {
        model?.addPointToCurrentLine(point: point)
        
    }
    
    func addLastPointToCurrentLine(point: CGPoint) {
        model?.addLastPointToCurrentLine(point: point)
    }
    
    func getAllPaths() -> [UIBezierPath] {
        return (model?.getAllPaths())!
    }
}
