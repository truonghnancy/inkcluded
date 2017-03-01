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
    var strokes: [Stroke]?

    @IBOutlet weak var canvas: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    
    private var menu: CanvasMenuView?
    var selectImageVC: SelectImageViewController?
    private var orderedSubViews: [UIView] = [] // 0: drawView 1:sendButton 2:loadButton 3:menu
    
    var model: CanvasModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialization
        drawView = getNewDrawView()
        strokes = []
        model = CanvasModel()
        menu = CanvasMenuView(size: self.view.frame.size)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        selectImageVC = storyboard.instantiateViewController(withIdentifier: "selectImageVC") as? SelectImageViewController
        
        // Set up view
        self.view.backgroundColor = UIColor.white
        
        // Bindings
        menu?.delegate = self;
        selectImageVC?.selectImageDelegate = self
        
        // Add subviews
        self.orderedSubViews.append(drawView!)
        self.orderedSubViews.append(sendButton)
        self.orderedSubViews.append(loadButton)
        self.orderedSubViews.append(menu!)
        
        canvas.addSubview(drawView!)
        canvas.addSubview(menu!)
        
        bringSubViewToFrontInOrder()
    }
    
    /**
     * Saves the canvas tot he default canvas path. The default will doc path is:
     * /Users/<USER>/Library/Developer/CoreSimulator/Devices/<SIMULATOR-ID>/data/Containers/Data/Application/<APP-ID>/Documents/
     *
     **/
    @IBAction func sendButtonPressed(_ sender: Any) {
        model!.saveCanvasElements(drawViewSize: (drawView?.bounds.size)!)
    }
    
    // Loads a completely new canvas and discards the old canvas. Placeholder button just for canvas bugtesting.
    @IBAction func loadButtonPressed(_ sender: Any) {
        drawView?.removeFromSuperview();
        
        drawView = getNewDrawView()

        // Clear and restore context
        model?.clearCanvasElements()
        let renderElements = model?.restoreStateFromWILLFile()
        drawView?.renderWILLSection(elements: renderElements!)
        
        canvas.addSubview(drawView!)
        self.orderedSubViews[0] = drawView!
        
        self.bringSubViewToFrontInOrder()
    }
    
    /**
     * Helper Functions
     */
    func getNewDrawView() -> DrawView {
        let newDrawView = DrawView(frame: canvas.bounds)
        newDrawView.setNewDelegate(newDelegate: self)
        
        return newDrawView
    }
    
    func bringSubViewToFrontInOrder() {
        for view in self.orderedSubViews {
            canvas.bringSubview(toFront: view)
        }
    }
}

extension CanvasViewController: CanvasMenuDelegate {
    func didClickOnMenuItem(item: CanvasMenuItem) {
        switch item {
        case .INSERT_IMAGE:
            self.present(self.selectImageVC!, animated: true, completion: nil)
            break
        case .INSERT_TEXT:
            // TODO: replace these magic numbers
            var myField: UITextField = UITextField (frame:CGRect.init(x: 50, y: 50, width: 100, height: 50));
            myField.borderStyle = UITextBorderStyle.bezel
            myField.delegate = self
            self.drawView!.addSubview(myField)
            self.view.becomeFirstResponder()
            // TODO: figure out how to serialize
            break
        default:
            break
        }
    }
}

extension CanvasViewController: SelectImageDelegate {
    func didSelectImage(image: DraggableImageView) {
        image.frame.origin = CGPoint(x: (canvas.frame.width - image.frame.width) / 2, y: (canvas.frame.height - image.frame.height) / 2)
        self.drawView!.addSubview(image)
        self.model!.appendElement(elem: image)
    }
}

extension CanvasViewController: DrawStrokesDelegate {
    func addStroke(stroke: Stroke) {
        model!.appendElement(elem: stroke)
    }
    
    func clearStrokes() {
        model!.clearCanvasElements()
    }
    
    func getAllStrokes() -> [Stroke] {
        return strokes!
    }
}

extension CanvasViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.drawView!.endEditing(true)
        return true
    }
}
