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
    
    func saveCanvasElements(drawViewSize: CGSize) {
        let inkEncoder = WCMInkEncoder()
        let doc = WCMDocument()
        let section = WCMDocumentSection()
        
        // set the size of the section
        section.size = drawViewSize
        
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
            else if let imageElem = elem as? DraggableImageView {
                let imageData = UIImagePNGRepresentation(imageElem.image!)
                let willImage = WCMDocumentSectionImage()
                willImage.content.setData(imageData, with: WCMDocumentContentType.png())
                willImage.rect = imageElem.frame
                
                // add it to the section
                section.add(willImage)
            }
            else {
                print("Not expecting this type yet")
                print(elem.self)
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
    
    func restoreStateFromWILLFile() -> [AnyObject] {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let willDocPath = documentsPath.appending(WILL_DOCUMENT_NAME)
        let doc = WCMDocument()
        
        doc.load(atPath: willDocPath)
        
        let section = doc.sections![0] as! WCMDocumentSection
        
        for element in section.subelements {
            if let strokeElement = element as? WCMDocumentSectionPaths {
                let inkData = strokeElement.content.loadData()
                let decoder = WCMInkDecoder(data: inkData)
                
                var strokePoints: WCMFloatVector? = WCMFloatVector()
                var strokeStride: UInt32 = UInt32()
                var strokeWidth: Float = Float()
                var strokeColor: UIColor? = UIColor()
                var strokeStartValue: Float = Float()
                var strokeFinishValue: Float = Float()
                var blendMode: WCMBlendMode = WCMBlendMode(rawValue: 0)!
                
                while (decoder?.decodePath(
                    toPoints: &strokePoints,
                    andStride: &strokeStride,
                    andWidth: &strokeWidth,
                    andColor: &strokeColor,
                    andTs: &strokeStartValue, 
                    andTf: &strokeFinishValue,
                    andBlendMode: &blendMode))!
                {
                    let stroke = Stroke(
                        points: strokePoints,
                        andStride: Int32(strokeStride),
                        andWidth: strokeWidth,
                        andColor: strokeColor,
                        andTs: strokeStartValue,
                        andTf: strokeFinishValue,
                        andBlendMode: blendMode
                    )
                    
                    appendElement(elem: stroke!)
                }
            }
            else if let imageElement = element as? WCMDocumentSectionImage {
                let imageData = imageElement.content.loadData()
                let image = UIImage(data: imageData!)
                let imageView = DraggableImageView(image: image)
                imageView.frame = imageElement.rect
                
                appendElement(elem: imageView)
            }
            else {
                print("Not expecting this type")
            }
        }
    
        return canvasElements
    }
}
