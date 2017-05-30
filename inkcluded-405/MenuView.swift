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
        versionLabel.text = "v0.1.6"
        versionLabel.textAlignment = .center
        self.addSubview(versionLabel)
        
        let feedbackButton = UIButton(frame: CGRect(x: 0, y: 125, width: self.frame.width, height: 100))
        feedbackButton.backgroundColor = UIColor(colorLiteralRed: 99.0/255.0, green: 174/255.0, blue: 245.0/255.0, alpha: 1.0)
        feedbackButton.setTitle("Feedback", for: .normal)
        feedbackButton.addTarget(self, action: #selector(self.didClickOnFeedbackButton), for: UIControlEvents.touchUpInside)
        self.addSubview(feedbackButton)
        
        let logoutButton = UIButton(frame: CGRect(x: 0, y: self.frame.height - 50, width: self.frame.width, height: 25))
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(UIColor.black, for: .normal)
        logoutButton.addTarget(self, action: #selector(self.didClickOnLogoutButton), for: UIControlEvents.touchUpInside)
        self.addSubview(logoutButton)
        
        let tutorialButton = UIButton(frame: CGRect(x: 0, y: 225, width: self.frame.width, height: 100))
        tutorialButton.backgroundColor = UIColor(colorLiteralRed: 75.0/255.0, green: 177.0/255.0, blue: 86.0/255.0, alpha: 1.0)
        tutorialButton.setTitle("Tutorial", for: .normal)
        tutorialButton.addTarget(self, action: #selector(self.didClickOnTutorialButton), for: UIControlEvents.touchUpInside)
        self.addSubview(tutorialButton)
    }
    
    func didClickOnLogoutButton() {
        delegate?.didClickOnLogoutButton()
    }
    
    func didClickOnFeedbackButton() {
        delegate?.didClickOnFeedbackButton()
    }
    
    func didClickOnTutorialButton() {
        delegate?.didClickOnTutorialButton()
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
