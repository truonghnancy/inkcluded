//
//  CanvasModel.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 2/21/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation

class CanvasModel {
    let WILL_DOCUMENT_NAME = "document.will"
    var canvasElements: [AnyObject]
    var drawViewSize: CGSize?
    
    init() {
        self.canvasElements = []
    }
    
    func appendElement(elem: AnyObject) {
        canvasElements.append(elem)
    }
    
    func clearCanvasElements() {
        canvasElements.removeAll()
    }
    
    func getCanvasElements() -> [AnyObject] {
        return canvasElements
    }

    func setDrawViewSize(size: CGSize) {
        drawViewSize = size
    }
    
    func saveCanvasElements() {
        let inkEncoder = WCMInkEncoder()
        let doc = WCMDocument()
        let section = WCMDocumentSection()
        
        // set the size of the section
        section.size = drawViewSize!
        
        for elem in canvasElements {
            // if the element is a stroke
            if let strokeElem = elem as? Stroke {
                inkEncoder.encodePath(
                    withPrecision: 2,
                    andPoints: strokeElem.points,
                    andStride: UInt32(strokeElem.stride),
                    andWidth: strokeElem.width,
                    andColor: strokeElem.color,
                    andTs: 0,
                    andTf: 1,
                    andBlendMode: WCMBlendMode.normal
                )
                let inkData = inkEncoder.getBytes()
                let path = WCMDocumentSectionPaths()
                path.content.setData(inkData, with: WCMDocumentContentType.strokes())
                
                // add it to the section
                section.add(path)
            }
            // if the element is a imageView
            else if let imageElem = elem as? UIImageView {
                let imageData = UIImagePNGRepresentation(imageElem.image!)
                let willImage = WCMDocumentSectionImage()
                willImage.content.setData(imageData, with: WCMDocumentContentType.png())
                
                // add it to the section
                section.add(willImage)
            }
        }
        
        // Add section to document
        doc.sections.add(section)
        
        // Set the document path
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let willDocPath = documentsPath.appending(WILL_DOCUMENT_NAME)
        
        // Create and write to the file
        doc.createDocument(atPath: willDocPath)
    }
    
    func decodeWILLFile() -> WCMDocumentSection {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let willDocPath = documentsPath.appending(WILL_DOCUMENT_NAME)
        let doc = WCMDocument()
        
        doc.load(atPath: willDocPath)
        
        return doc.sections![0] as! WCMDocumentSection;
    }
}
