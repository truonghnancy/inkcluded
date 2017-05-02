//
//  MenuView.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 4/17/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import UIKit

class MenuView: UIView {

    private var delegate: MenuViewDelegate?

    convenience init(frame: CGRect, delegate: MenuViewDelegate) {
        self.init(frame: frame)
        
        self.delegate = delegate
        
        self.backgroundColor = UIColor.white
        
        let versionLabel = UILabel(frame: CGRect(x: 0, y:75, width: self.frame.width, height: 25))
        versionLabel.text = "v0.1.4"
        versionLabel.textAlignment = .center
        self.addSubview(versionLabel)
        
        let feedbackButton = UIButton(frame: CGRect(x: 0, y: 125, width: self.frame.width, height: 100))
        feedbackButton.backgroundColor = UIColor(colorLiteralRed: 99.0/255.0, green: 174/255.0, blue: 245.0/255.0, alpha: 1.0)
        feedbackButton.setTitle("Feedback", for: .normal)
        
        feedbackButton.addTarget(self, action: #selector(self.didClickOnFeedbackButton), for: UIControlEvents.touchUpInside)
        
        self.addSubview(feedbackButton)
    }
    
    func didClickOnFeedbackButton() {
        delegate?.didClickOnFeedbackButton()
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
