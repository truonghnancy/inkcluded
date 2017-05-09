//
//  GroupHistoryDrawView.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 5/6/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

class GroupHistoryDrawView: DrawView {
    var groupMessageIndex: Int?

    convenience init(frame: CGRect, groupMessageIndex index: Int) {
        self.init(frame: frame)
        self.groupMessageIndex = index
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.shouldDraw = false
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
