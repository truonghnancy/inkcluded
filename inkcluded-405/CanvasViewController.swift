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
    var willSize: CGSize? // original size of the will canvas

    @IBOutlet var sendButton: UIBarButtonItem!
    @IBOutlet weak var canvas: UIView!
    
    var menu: CanvasMenuView?
    var selectImageVC: SelectImageViewController?
    private var orderedSubViews: [UIView] = [] // 0: drawView 1:menu
    
    var msgGroup: Group?
    
    var model: CanvasModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialization
        drawView = getNewDrawView()
        if (model == nil) {
            model = CanvasModel()
        }
        menu = CanvasMenuView(size: self.view.frame.size, delegate: self)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        selectImageVC = storyboard.instantiateViewController(withIdentifier: "selectImageVC") as? SelectImageViewController
        
        canvas.backgroundColor = UIColor.gray
        
        // Bindings
        selectImageVC?.selectImageDelegate = self
        
        // Add subviews
        self.orderedSubViews.append(drawView!)
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
        // Disable the send button
        self.sendButton.isEnabled = false
    
        // Set the document path
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let timestamp = String(format: "%llu", UInt64(floor(NSDate().timeIntervalSince1970 * 1000)));
        let curUser = APICalls.sharedInstance.currentUser
        var docName = (curUser?.id)! + timestamp
        docName = docName.appending(".will")
        let willDocPath = documentsPath.appending("/\(docName)")
        
        let size = CGSize(width: (drawView?.bounds.size.height)!, height: (drawView?.bounds.size.height)!)
        if !(model!.saveCanvasElements(drawViewSize: size, toFile: willDocPath)) {
            self.failedToSendMessage()
            return
        }
        
        let sendMessage = Message(
            filepath: willDocPath,
            filename: docName,
            groupid: (msgGroup?.id)!,
            timestamp: timestamp,
            senderid: (curUser?.id)!,
            senderfirstname: (curUser?.firstName)!
        )
        
        let loadView = LoadView(frame: self.view.frame)
        self.view.addSubview(loadView)
        APICalls.sharedInstance.sendMessage(message: sendMessage) { (isSent) in
            if isSent {
                loadView.removeFromSuperview()
                OperationQueue.main.addOperation {
                    let _ = self.navigationController?.popViewController(animated: false)
                }
            }
            else {
                loadView.removeFromSuperview()
            
                self.failedToSendMessage()
            }
            
            DispatchQueue.main.async {
                self.sendButton.isEnabled = true
            }
        }
    }
    
    func failedToSendMessage() {
        let alert = UIAlertController(title: "Error", message: "Failed to Send Message", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    func restoreState(fromElements elements: [AnyObject], atSize size: CGSize) {
        if model == nil {
            model = CanvasModel()
        }
        model?.clearCanvasElements()
        model?.restoreState(fromElements: elements)
        self.willSize = size
        resetDrawView(withElements: elements)
    }
    
    func resetDrawView(withElements elements: [AnyObject]) {
        drawView?.removeFromSuperview()
        
        drawView = getNewDrawView()
        
        var scaledElements: [AnyObject]
        if let size = self.willSize {
            scaledElements = (drawView?.refreshViewWithElements(elements: elements, atSize: size))!
        }
        else {
            scaledElements = (drawView?.refreshViewWithElements(elements: elements, atSize: (drawView?.frame.size)!))!
        }
        
        self.model?.clearCanvasElements()
        self.model?.restoreState(fromElements: scaledElements)
        
        canvas.addSubview(drawView!)
        self.orderedSubViews[0] = drawView!
        
        self.bringSubViewToFrontInOrder()
    }
    
    /**
     * Helper Functions
     */
    func getNewDrawView() -> DrawView {
        let size = self.view.bounds.width
        let yOffset = self.view.bounds.height / 5
        let newDrawView = DrawView(frame: CGRect(x: 0, y: yOffset, width: size, height: size))
        newDrawView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0)
        newDrawView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0)
        newDrawView.center = self.view.center
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
            let myField: DraggableTextView = DraggableTextView(frame: CGRect.init(x: 50, y: 50, width: 150, height: 50));
            myField.delegate = self
            self.drawView!.addSubview(myField)
            self.view.becomeFirstResponder()
            self.model?.appendElement(elem: myField)
            // TODO: figure out how to serialize
            break
        case .UNDO:
            let _ = self.model?.popMostRecentElement()
            resetDrawView(withElements: (self.model?.getCanvasElements())!)
            break
        }
        
        // Refresh the menu
        self.menu?.refreshView()
    }
    
    func shouldEnableMenuItem(item: CanvasMenuItem) -> Bool {
        if (item == .UNDO && self.model?.getCanvasElements().count == 0) {
            return false;
        }
        
        return true;
    }
}

extension CanvasViewController: SelectImageDelegate {
    func didSelectImage(image: DraggableImageView) {
        image.frame.origin = CGPoint(x: (canvas.frame.width - image.frame.width) / 2, y: (canvas.frame.height - image.frame.height) / 2)
        self.drawView!.addSubview(image)
        self.model!.appendElement(elem: image)
        self.menu?.refreshView()
    }
}

extension CanvasViewController: DrawStrokesDelegate {
    func addStroke(stroke: Stroke) {
        model!.appendElement(elem: stroke)
        self.menu?.refreshView()
    }
    
    
    func clearStrokes() {
        model!.clearCanvasElements()
        self.menu?.refreshView()
    }
    
    func getAllStrokes() -> [Stroke] {
        return (model?.getCanvasElements().filter({ (element) -> Bool in
            return ((element as? Stroke) != nil)
        }))! as! [Stroke]
    }
}

extension CanvasViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        var textFrame = textView.frame
        textFrame.size.height = textView.contentSize.height
        textView.frame = textFrame
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let draggableTextView = textView as? DraggableTextView
        draggableTextView?.configureDraggableGestureRecognizers()
        self.drawView!.endEditing(true)
        textView.isSelectable = false
    }
}
