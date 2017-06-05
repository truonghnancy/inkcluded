//
//  LoadView.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 3/10/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

class LoadView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let loadIndicator = UIActivityIndicatorView(
                             frame:CGRect(
                                    x: 100, y: 100,
                                    width: 100, height: 100))
                             as UIActivityIndicatorView
        loadIndicator.activityIndicatorViewStyle =
         UIActivityIndicatorViewStyle.whiteLarge
        loadIndicator.center = self.center
        loadIndicator.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        
        self.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.0,
                                       blue: 0.0, alpha: 0.25)
        self.addSubview(loadIndicator)
        loadIndicator.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
