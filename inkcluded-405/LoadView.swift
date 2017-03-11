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
        
        let loaderImage = UIImage.animatedImageNamed("loader_", duration: 1.3)
        let imageView = UIImageView(image: loaderImage)
        imageView.center = self.center
        
        self.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.1)
        
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
