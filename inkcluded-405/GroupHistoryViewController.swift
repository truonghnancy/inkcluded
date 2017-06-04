//
//  GroupHistoryViewController.swift
//  inkcluded-405
//
//  Created by Christopher on 2/20/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

class GroupHistoryViewController: UIViewController {
    
    var curGroup: Group?
    var curMessages: [Message]?
    var contentView: UIView?
    var messageElements: [([AnyObject], CGSize)]?
    var beginning: Int?
    var end: Int?
    var cyPos: CGFloat?
    var isCalled = false
    
    @IBOutlet var historyView: UIScrollView!
    @IBOutlet var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.title = curGroup?.groupName
        self.messageElements = []
        self.curMessages = []
        
        // Why is this not on by default? Don't let users go forwards and
        //  backwards at the same time.
        self.navigationController?.navigationBar.isExclusiveTouch = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-2] is RecipientsViewController) {
            self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count)!-2)
        }
        
        let loadView = LoadView(frame: self.view.frame)
        self.view.addSubview(loadView)
        APICalls.sharedInstance.getAllMessage(groupId: (curGroup?.id)!) { (messages) in
            if messages == nil {
                self.curMessages = []
            }
            else {
                self.curMessages = messages
                if self.curMessages!.count - 10 >= 0 {
                    self.beginning = self.curMessages!.count - 10
                }
                else {
                    self.beginning = 0
                }
                self.end = self.curMessages!.count
                self.initialLoadAllMessages()
                self.historyView.delegate = self
            }
            
            loadView.removeFromSuperview()
        }
    }
    
    @IBAction func backToGroups(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToGroups", sender: self)
    }
    
    func __nextTopMessages() -> [Message] {
        let remaining = self.beginning! - 10
        if remaining < 0 {
            return Array(self.curMessages![0...self.beginning! - 1])
        }
        else {
            return Array(self.curMessages![self.beginning! - 10...self.beginning! - 1])
        }
    }
    
    func initialLoadAllMessages() {
        if self.curMessages!.count == 0 {
            return
        }
        let cmessages = self.curMessages![self.beginning!...self.curMessages!.count - 1]
        let parentSize = self.view.frame.size
        let drawViewSize = CGSize(width: parentSize.width / 2, height: parentSize.width / 2)
        let leftX: CGFloat = 5.0
        let rightX = parentSize.width - drawViewSize.width - leftX
        let padding: CGFloat = 10.0
        let nameFieldHeight: CGFloat = 15.0
        let contentViewHeight = CGFloat(cmessages.count) * (padding + drawViewSize.height + nameFieldHeight)
        
        if contentView != nil {
            contentView?.removeFromSuperview()
        }
        contentView = MessageHistoryView(frame: CGRect(x: 0, y: 0, width: parentSize.width, height: contentViewHeight))
        self.historyView.contentSize = contentView!.frame.size
        self.historyView.addSubview(contentView!)
        
        self.historyView.setContentOffset(CGPoint(x: 0, y: contentViewHeight - self.view.frame.height), animated: false)
        
        var yPos: CGFloat = nameFieldHeight
        
        for message in cmessages {
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
        
            // Decode elements from the will file
            let willContents = CanvasModel.decodeObjectsFromWillFile(textViewDelegate: nil, atPath: message.filepath)
            let elements = willContents?.0
            let willSize = willContents?.1
            
            // Create the draw view
            let drawView = GroupHistoryDrawView(frame: CGRect(origin: origin, size: drawViewSize), groupMessageIndex: (messageElements?.count)!)
            // add a gesture recognizer
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.respondToMessageTap(recognizer:)))
            drawView.addGestureRecognizer(tapRecognizer)
            
            if let drawViewContent = elements {
                drawView.refreshViewWithElements(elements: drawViewContent, atSize: willSize!)
                messageElements?.append((drawViewContent, willSize!))
            }
            else {
                drawView.backgroundColor = UIColor.black
                messageElements?.append(([], CGSize(width: 0, height: 0)))
            }
            
            contentView?.addSubview(nameField)
            contentView?.addSubview(drawView)
            
            yPos += CGFloat(drawViewSize.height) + padding + nameFieldHeight
        }
        cyPos = 0
    }
    
    func loadTopMessages() {
        if beginning! <= 0 {
            return
        }
        let cmessages = __nextTopMessages()
        let setSize = cmessages.count
        let parentSize = self.view.frame.size
        let drawViewSize = CGSize(width: parentSize.width / 2, height: parentSize.width / 2)
        let leftX: CGFloat = 5.0
        let rightX = parentSize.width - drawViewSize.width - leftX
        let padding: CGFloat = 10.0
        let nameFieldHeight: CGFloat = 15.0
        let messageSize = CGFloat(drawViewSize.height) + padding + nameFieldHeight
        let contentViewHeight = CGFloat((self.end! - self.beginning!) + setSize) * messageSize
        var yPos: CGFloat = nameFieldHeight + cyPos!
        let myDispatchGroup = DispatchGroup()
        
        var decodedMessages: [(UILabel, GroupHistoryDrawView)] = []
        DispatchQueue.global(qos: .userInitiated).async {
            var index = 0
            
            for message in cmessages.reversed() {
                myDispatchGroup.enter()
                let decodedMessage = CanvasModel.decodeObjectsFromWillFile(textViewDelegate: nil, atPath: message.filepath)
                
                yPos -= messageSize
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
                
                let elements = decodedMessage!.0
                let willSize = decodedMessage!.1
                
                // Create the draw view
                let drawView = GroupHistoryDrawView(frame: CGRect(origin: origin, size: drawViewSize), groupMessageIndex: (self.messageElements?.count)!)
                // add a gesture recognizer
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.respondToMessageTap(recognizer:)))
                drawView.addGestureRecognizer(tapRecognizer)
                
                if let drawViewContent = elements {
                    drawView.refreshViewWithElements(elements: drawViewContent, atSize: willSize)
                    self.messageElements?.append((drawViewContent, willSize))
                }
                else {
                    drawView.backgroundColor = UIColor.black
                    self.messageElements?.append(([], CGSize(width: 0, height: 0)))
                }
                
                decodedMessages.append(nameField, drawView)
                
                index += 1
                myDispatchGroup.leave()
            }
            
            myDispatchGroup.notify(queue: .main, execute: {
                for x in 0 ..< cmessages.count {
                    self.contentView?.addSubview(decodedMessages[x].0)
                    self.contentView?.addSubview(decodedMessages[x].1)
                }
                
                self.contentView?.frame = CGRect(x: 0, y: -1 * yPos + nameFieldHeight, width: parentSize.width, height: contentViewHeight)
                self.historyView.contentSize = self.contentView!.frame.size
                //self.historyView.contentSize.height += contentViewHeight
                
                self.historyView.setContentOffset(CGPoint(x: 0, y: messageSize * CGFloat(setSize) + self.historyView.contentOffset.y), animated: false)
                
                self.cyPos = yPos - nameFieldHeight
                self.beginning! -= cmessages.count
                self.isCalled = false
            })
        }
    }
    
    func respondToMessageTap(recognizer: UITapGestureRecognizer) {
        let drawView = recognizer.view as? GroupHistoryDrawView
        let elements = messageElements?[(drawView?.groupMessageIndex)!].0
        let size = messageElements?[(drawView?.groupMessageIndex)!].1
        
        self.performSegue(withIdentifier: "newMessageSegue", sender: (elements, size))
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newMessageSegue" {
            let destination = segue.destination as? CanvasViewController
            destination?.msgGroup = curGroup
            if let elementsTuple = sender as? ([AnyObject], CGSize) {
                destination?.restoreState(fromElements: elementsTuple.0, atSize: elementsTuple.1)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension GroupHistoryViewController: UIScrollViewDelegate  {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isCalled && scrollView.contentOffset.y <= 0){
            isCalled = true
            self.loadTopMessages()
        }
    }
}

/** This segment found at https://stackoverflow.com/questions/11770743/capturing-touches-on-a-subview-outside-the-frame-of-its-superview-using-hittest
 *  to recognize gestures outside of frame MessageViewFrame once frame is resized
 **/
class MessageHistoryView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (!self.clipsToBounds && !self.isHidden && self.alpha > 0.0) {
            let subviews = self.subviews.reversed()
            for member in subviews {
                let subPoint = member.convert(point, from: self)
                if let result:UIView = member.hitTest(subPoint, with:event) {
                    return result;
                }
            }
        }
        return nil
    }
}
