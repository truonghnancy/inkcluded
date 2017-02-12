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
    
    private var drawView: DrawView?

    @IBOutlet weak var canvas: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    
    private var menu: CanvasMenuView?
    
    /**
     * Saves the canvas tot he default canvas path. The default will doc path is:
     * /Users/<USER>/Library/Developer/CoreSimulator/Devices/<SIMULATOR-ID>/data/Containers/Data/Application/<APP-ID>/Documents/
     *
     **/
    @IBAction func sendButtonPressed(_ sender: Any) {
        drawView?.saveStrokes();
        
        // CODE SMELL: these 3 functions will print out the destination in the simulator the will doc is saved to
        //let fileManager = FileManager.default
        //let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first as? NSURL
        //print(url)
    }
    
    // Loads a completely new canvas and discards the old canvas. Placeholder button just for canvas bugtesting.
    @IBAction func loadButtonPressed(_ sender: Any) {
        drawView?.removeFromSuperview();
        
        drawView = DrawView(frame: canvas.bounds)
        drawView?.decodeStrokesFromDocumentPath();
        
        canvas.addSubview(drawView!)
        canvas.bringSubview(toFront: sendButton)
        canvas.bringSubview(toFront: loadButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        drawView = DrawView(frame: canvas.bounds)
        
        menu = CanvasMenuView(size: self.view.frame.size)
        menu?.delegate = self;
        
        canvas.addSubview(menu!)
        canvas.addSubview(drawView!)
        //drawView?.frame = canvas.bounds
        canvas.bringSubview(toFront: sendButton)
        canvas.bringSubview(toFront: loadButton)
        canvas.bringSubview(toFront: menu!)
    }
}

extension CanvasViewController: CanvasMenuDelegate {
    func didClickOnMenuItem(item: CanvasMenuItem) {
        
    }
}
