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
    
    
    @IBOutlet weak var canvas: UIView!
    private var drawView: DrawView?
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        drawView?.saveStrokes();
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first as? NSURL
        print(url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        drawView = DrawView(frame: self.view.frame)
        
        canvas.addSubview(drawView!)
        drawView?.frame = canvas.bounds
        canvas.bringSubview(toFront: sendButton)
    }
}
