//
//  DrawStrokesDelegate.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 2/21/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation

@objc protocol DrawStrokesDelegate {
    func addStroke(stroke: Stroke);
    
    func clearStrokes();
    
    func getAllStrokes() -> [Stroke];
}
