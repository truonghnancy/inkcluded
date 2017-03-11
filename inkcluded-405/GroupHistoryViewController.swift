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
    
    @IBOutlet var historyView: UIScrollView!
    @IBOutlet var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.title = curGroup?.groupName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let loadView = LoadView(frame: self.view.frame)
        self.view.addSubview(loadView)
        APICalls.sharedInstance.getAllMessage(groupId: (curGroup?.id)!) { (messages) in
            self.curMessages = messages;
            self.loadAllMessages()
            loadView.removeFromSuperview()
        }
    }
    
    func loadAllMessages() {
        let parentSize = self.view.frame.size
        let drawViewSize = CGSize(width: parentSize.width / 2, height: parentSize.height / 2)
        let leftX: CGFloat = 5.0
        let rightX = parentSize.width - drawViewSize.width - leftX
        let padding: CGFloat = 10.0
        let nameFieldHeight: CGFloat = 15.0
        let contentViewHeight = CGFloat(self.curMessages!.count) * (padding + drawViewSize.height + nameFieldHeight)
        
        if contentView != nil {
            contentView?.removeFromSuperview()
        }
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: parentSize.width, height: contentViewHeight))
        self.historyView.contentSize = contentView!.frame.size
        self.historyView.addSubview(contentView!)
        
        var yPos: CGFloat = nameFieldHeight
        
        for message in self.curMessages! {
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
            let elements = CanvasModel.decodeObjectsFromWillFile(textViewDelegate: nil, atPath: message.filepath)
            drawView.isUserInteractionEnabled = false
            drawView.layer.borderWidth = 1.0
            drawView.layer.borderColor = UIColor.black.cgColor
            
            if let drawViewContent = elements {
                drawView.refreshViewWithElements(elements: drawViewContent)
            }
            else {
                drawView.backgroundColor = UIColor.black
            }
            
            contentView?.addSubview(nameField)
            contentView?.addSubview(drawView)
            
            yPos += CGFloat(drawViewSize.height) + padding + nameFieldHeight
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newMessageSegue" {
            let destination = segue.destination as? CanvasViewController
            destination?.msgGroup = curGroup
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
