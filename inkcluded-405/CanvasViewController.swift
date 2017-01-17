//
//  CanvasViewController.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/13/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit
import MROGeometry

class CanvasViewController: UIViewController {
    @IBOutlet var canvasView: CanvasView!
    private var model: CanvasModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = CanvasModel()
        canvasView.controller = self
    }
    @IBAction func sendButtonPressed(_ sender: Any) {
        makeSerializedCanvas()
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
    
    func makeSerializedCanvas() {
        let bezierpaths : [UIBezierPath]? = getAllPaths()
        
        for bzpath in (bezierpaths)! {
            
            // string that holds all the points in one Bezier Path
            let string = String(cString: CGPathToCString(bzpath.cgPath, 0, 0))
            print(string)
        }
    }
}
