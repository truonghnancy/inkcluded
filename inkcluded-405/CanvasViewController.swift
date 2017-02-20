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
    
    var drawView: DrawView?

    @IBOutlet weak var canvas: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    
    private var menu: CanvasMenuView?
    var selectImageVC: SelectImageViewController?
    private var orderedSubViews: [UIView] = [] // 0: drawView 1:sendButton 2:loadButton 3:menu
    
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
        self.orderedSubViews[0] = drawView!
        
        self.bringSubViewToFrontInOrder()
    }
    
    func bringSubViewToFrontInOrder() {
        for view in self.orderedSubViews {
            canvas.bringSubview(toFront: view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        drawView = DrawView(frame: canvas.bounds)
        
        menu = CanvasMenuView(size: self.view.frame.size)
        menu?.delegate = self;
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        selectImageVC = storyboard.instantiateViewController(withIdentifier: "selectImageVC") as? SelectImageViewController
        selectImageVC?.selectImageDelegate = self
        
        self.orderedSubViews.append(drawView!)
        self.orderedSubViews.append(sendButton)
        self.orderedSubViews.append(loadButton)
        self.orderedSubViews.append(menu!)
        
        canvas.addSubview(drawView!)
        canvas.addSubview(menu!)
        
        bringSubViewToFrontInOrder()
    }
}

extension CanvasViewController: CanvasMenuDelegate {
    func didClickOnMenuItem(item: CanvasMenuItem) {
        if item == .INSERT_IMAGE {
            self.present(self.selectImageVC!, animated: true, completion: nil)
        }
    }
}

extension CanvasViewController: SelectImageDelegate {
    func didSelectImage(image: UIImageView) {
        image.frame.origin = CGPoint(x: (canvas.frame.width - image.frame.width) / 2, y: (canvas.frame.height - image.frame.height) / 2)
        self.drawView!.addSubview(image)
    }
}
