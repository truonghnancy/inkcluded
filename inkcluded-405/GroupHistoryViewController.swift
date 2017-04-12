//
//  GroupHistoryViewController.swift
//  inkcluded-405
//
//  Created by Christopher on 2/20/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

class GroupHistoryViewController: UIViewController, UIScrollViewDelegate {
    
    var curGroup: Group?
    var curMessages: [Message] = []
    var contentView: UIView?
    var messageElements: [[AnyObject]] = []
    var messageDrawViews: [DrawView] = []
    var isDownloadingMessages: Bool = false
    
    @IBOutlet var historyView: UIScrollView!
    @IBOutlet var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.title = curGroup?.groupName
        self.messageElements = []
        self.curMessages = []
        self.messageDrawViews = []
        self.isDownloadingMessages = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let loadView = LoadView(frame: self.view.frame)
        self.view.addSubview(loadView)
        APICalls.sharedInstance.getAllMessage(groupId: (curGroup?.id)!) { (messages) in
            if messages == nil {
                self.curMessages = []
            }
            else {
                self.curMessages = messages!
                self.loadAllMessages()
            }
            
            loadView.removeFromSuperview()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleDrawViews = self.messageDrawViews.filter({ (drawView) -> Bool in
            let yPos = drawView.frame.origin.y
            let max = scrollView.contentOffset.y + self.view.frame.height
            let min = scrollView.contentOffset.y - self.view.frame.height
            
            return !drawView.isLoaded && yPos >= min && yPos <= max
        })
        
        for drawView in visibleDrawViews {
            let message = curMessages[drawView.groupMessageIndex!]
            
            // Set the is loaded flag so it won't load again
            drawView.isLoaded = true
            
            message.getContents(closure: { (elements) in
                if let drawViewContent = elements {
                    self.messageElements[drawView.groupMessageIndex!] = drawViewContent
                    drawView.refreshViewWithElements(elements: drawViewContent)
                }
                else {
                    drawView.isLoaded = false
                }
            })
        }
    }
    
    func loadAllMessages() {
        let parentSize = self.view.frame.size
        let drawViewSize = CGSize(width: parentSize.width / 2, height: parentSize.height / 2)
        let leftX: CGFloat = 5.0
        let rightX = parentSize.width - drawViewSize.width - leftX
        let padding: CGFloat = 10.0
        let nameFieldHeight: CGFloat = 15.0
        let contentViewHeight = CGFloat(self.curMessages.count) * (padding + drawViewSize.height + nameFieldHeight)
        let visibleRange = contentViewHeight - self.view.frame.height * 2
        
        let isWithinVisibleRange = {(yPos) -> Bool in yPos >= visibleRange && yPos <= contentViewHeight}
        
        if contentView != nil {
            contentView?.removeFromSuperview()
        }
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: parentSize.width, height: contentViewHeight))
        self.historyView.contentSize = contentView!.frame.size
        self.historyView.addSubview(contentView!)
        self.historyView.setContentOffset(CGPoint(x:0 ,y: contentViewHeight - self.view.frame.height), animated: false)
        self.historyView.delegate = self
        
        self.messageElements = [[AnyObject]](repeating: [], count: self.curMessages.count)
        
        var yPos: CGFloat = nameFieldHeight
        var index = 0
        
        for message in self.curMessages {
            var origin = CGPoint(x: leftX, y: yPos)
            if message.senderid == APICalls.sharedInstance.currentUser?.id {
                origin.x = rightX
            }
        
            let nameFieldOrigin = CGPoint(x: origin.x, y: origin.y - nameFieldHeight)
            let nameField = UILabel(frame: CGRect(origin: nameFieldOrigin, size: CGSize(width: drawViewSize.width, height: nameFieldHeight)))
            nameField.text = message.senderfirstname
            nameField.font = UIFont(name: "AvenirNext-Medium", size: nameFieldHeight)
            if message.senderid == APICalls.sharedInstance.currentUser?.id {
                nameField.textAlignment = .right
            }
        
            let drawView = DrawView(frame: CGRect(origin: origin, size: drawViewSize))
            
            // Set the message index
            drawView.groupMessageIndex = index
            
            // download messages in range
            if isWithinVisibleRange(yPos) {
                message.getContents(closure: { (elements) in
                    if let drawViewContent = elements {
                        drawView.refreshViewWithElements(elements: drawViewContent)
                        self.messageElements[drawView.groupMessageIndex!] = drawViewContent
                        drawView.isLoaded = true
                    }
                })
            }
            
            // Set up the default look
            drawView.showLoading()
            
            // Format the view
            drawView.shouldDraw = false
            drawView.layer.borderWidth = 1.0
            drawView.layer.borderColor = UIColor.black.cgColor
            drawView.clipsToBounds = true
            
            // add a gesture recognizer
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.respondToMessageTap(recognizer:)))
            drawView.addGestureRecognizer(tapRecognizer)
            
            contentView?.addSubview(nameField)
            contentView?.addSubview(drawView)
            
            self.messageDrawViews.append(drawView)
            
            yPos += CGFloat(drawViewSize.height) + padding + nameFieldHeight
            
            index += 1
        }
    }
    
    func respondToMessageTap(recognizer: UITapGestureRecognizer) {
        let drawView = recognizer.view as? DrawView
        let elements = messageElements[(drawView?.groupMessageIndex)!]
        
        self.performSegue(withIdentifier: "newMessageSegue", sender: elements)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newMessageSegue" {
            let destination = segue.destination as? CanvasViewController
            destination?.msgGroup = curGroup
            if let elements = sender as? [AnyObject] {
                destination?.restoreState(fromElements: elements)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
