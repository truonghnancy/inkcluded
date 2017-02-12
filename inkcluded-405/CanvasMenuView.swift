//
//  CanvasMenuView.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 2/12/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import UIKit

enum CanvasMenuItem {
    case INSERT_IMAGE
}

public class CanvasMenuView: UIView {

    let MENU_WIDTH: CGFloat = 65.0
    let MENU_HEIGHT_RATIO: CGFloat = 0.5

    private var _delegate: CanvasMenuDelegate?
    var delegate: CanvasMenuDelegate {
        get {
            return self._delegate!
        }
        set(newVal) {
            self._delegate = newVal
        }
    }

    init(size: CGSize) {
        let origin = CGPoint(x: size.width - MENU_WIDTH, y: (size.height * MENU_HEIGHT_RATIO) / 2)
        let frameSize = CGSize(width: MENU_WIDTH, height: size.height * MENU_HEIGHT_RATIO)
        
        super.init(frame: CGRect(origin: origin, size: frameSize))
        self.backgroundColor = UIColor.red
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
