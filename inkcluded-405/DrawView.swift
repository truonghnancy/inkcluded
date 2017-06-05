//
//  DrawView.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 2/22/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    // Renderer of layers
    private var willContext: WCMRenderingContext!
    
    // The main viewable layer
    private var viewLayer: WCMLayer!
    
    // Strokes layer
    private var strokesLayer: WCMLayer!
    
    // Renderer for stroke layer
    private var strokeRenderer: WCMStrokeRenderer!
    
    // Helps build the path of strokes
    private var pathBuilder: WCMSpeedPathBuilder!
    
    // Help smooth out the paths
    private var pathSmoother: WCMMultiChannelSmoothener!
    
    // Path brush for redrawing strokes
    private var pathBrush: WCMStrokeBrush!
    
    // Delegate for saving strokes data
    private var delegate: DrawStrokesDelegate!
    
    private var pathStride: Int32!
    
    // Whether to allow strokes to be drawn
    var shouldDraw: Bool
    
    override init(frame: CGRect) {
        shouldDraw = true
        super.init(frame: frame)

        self.initWillContext()
        self.backgroundColor = UIColor.white
        willContext.setTarget(strokesLayer)
        willContext.clear(UIColor.clear)
    }
    
    // The layer class that is being wrapped by the WILL framework
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initWillContext() {
        if (willContext == nil) {
            self.contentScaleFactor = UIScreen.main.scale
            
            let eaglLayer = self.layer as! CAEAGLLayer
            eaglLayer.isOpaque = true
            eaglLayer.drawableProperties = [
                kEAGLDrawablePropertyRetainedBacking: NSNumber(booleanLiteral: true),
                kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
            ]
            
            let eaglContext = EAGLContext(api: .openGLES2)
            
            if (eaglContext == nil || !EAGLContext.setCurrent(eaglContext)) {
                print("Unable to create EAGLContext")
                return
            }
            
            self.willContext = WCMRenderingContext(eaglContext: eaglContext)
            
            self.viewLayer = willContext.layer(
                                from: self.layer as! EAGLDrawable,
                                withScaleFactor: Float(self.contentScaleFactor)
                             )
            
            self.strokesLayer = willContext.layer(
                                    withWidth: Int32(self.viewLayer.bounds.size.width),
                                    andHeight: Int32(self.viewLayer.bounds.size.height),
                                    andScaleFactor: Int32(self.viewLayer.scaleFactor),
                                    andUseTextureStorage: true
                                )
            
            self.pathBrush = willContext.solidColorBrush()
            
            self.pathBuilder = WCMSpeedPathBuilder()
            self.pathBuilder.setNormalizationConfigWithMinValue(0, andMaxValue: 7000)
            self.pathBuilder.setPropertyConfigWith(
                WCMPropertyName.width,
                andMinValue: 2,
                andMaxValue: 15,
                andInitialValue: Float.nan,
                andFinalValue: Float.nan,
                andFunction: WCMPropertyFunction.power,
                andParameter: 1,
                andFlip: false
            )
            
            self.pathStride = pathBuilder.calculateStride()
            
            self.pathSmoother = WCMMultiChannelSmoothener(channelsCount: self.pathStride)
            
            self.strokeRenderer = willContext.strokeRenderer(
                                      with: self.viewLayer.bounds.size,
                                      andScaleFactor: CGFloat(self.viewLayer.scaleFactor)
                                  )
            self.strokeRenderer.brush = willContext.solidColorBrush()
            self.strokeRenderer.stride = pathStride
            self.strokeRenderer.color = UIColor.black
        }
    }
    
    func setNewDelegate(newDelegate: DrawStrokesDelegate) {
        self.delegate = newDelegate
    }
    
    func refreshViewInRect(rect: CGRect) {
        willContext.setTarget(self.viewLayer, andClipRect: rect)
        willContext.clear(UIColor.white)
        
        willContext.draw(
            self.strokesLayer,
            withSourceRect: rect,
            andDestinationRect: rect,
            andBlendMode: WCMBlendMode.normal
        )
        strokeRenderer.blendStrokeUpdatedArea(in: self.viewLayer, with: WCMBlendMode.normal)
        
        viewLayer.present()
    }
    
    func processTouches(touches: Set<UITouch>, withEvent event: UIEvent) {
        let touch = touches[touches.index(touches.startIndex, offsetBy: 0)]
        
        if (shouldDraw && touch.phase != UITouchPhase.stationary) {
            let location = touch.location(in: self)
            var wcmInputPhase: WCMInputPhase? = nil
            
            if (touch.phase == UITouchPhase.began) {
                wcmInputPhase = WCMInputPhase.begin
                pathSmoother.reset()
            }
            else if (touch.phase == UITouchPhase.moved) {
                wcmInputPhase = WCMInputPhase.move
            }
            else if (touch.phase == UITouchPhase.ended || touch.phase == UITouchPhase.cancelled) {
                wcmInputPhase = WCMInputPhase.end
            }
            
            let points = pathBuilder.addPoint(
                            with: wcmInputPhase!,
                            andX: Float(location.x),
                            andY: Float(location.y),
                            andTimestamp: touch.timestamp
                         )
            let smoothedPoints = pathSmoother.smoothValues(
                                    points,
                                    reachFinalValues: wcmInputPhase == WCMInputPhase.end
                                 )
            let pathAppendResult = pathBuilder.addPathPart(smoothedPoints)
            
            let prelimPoints = pathBuilder.createPreliminaryPath()
            let smoothedPrelimPoints = pathSmoother.smoothValues(prelimPoints, reachFinalValues: true)
            let prelimPath = pathBuilder.finishPreliminaryPath(smoothedPrelimPoints)
            
            strokeRenderer.drawPoints(pathAppendResult?.addedPath, finishStroke: wcmInputPhase == WCMInputPhase.end)
            strokeRenderer.drawPreliminaryPoints(prelimPath)
            
            self.refreshViewInRect(rect: strokeRenderer.updatedArea)
            
            if (wcmInputPhase == WCMInputPhase.end) {
                strokeRenderer.blendStroke(in: strokesLayer, with: WCMBlendMode.normal)
                
                let stroke = Stroke(points: WCMFloatVector(
                                        begin: pathAppendResult?.wholePath.begin(),
                                        andEnd: pathAppendResult?.wholePath.end()),
                                    andStride: pathStride,
                                    andWidth: Float.nan,
                                    andColor: UIColor.black,
                                    andTs: 0,
                                    andTf: 1,
                                    andBlendMode: WCMBlendMode.normal)
                delegate.addStroke(stroke: stroke!)
            }
        }
    }
    
    func scaleStrokeVector(vector: WCMFloatVector, atScaleFactor scaleFactor: Float) -> WCMFloatVector {
        var cur = vector.begin()
        
        while (cur != vector.end()) {
            cur?.pointee = (cur?.pointee)! * scaleFactor
            cur = cur?.advanced(by: 1)
        }
    
        return vector
    }
    
    func determineScaleFactor(originalSize size: CGSize) -> Float {
        var newSize = CGSize(width: size.width, height: size.height)
        if (size.width == 0 || size.height == 0) {
            // Hacky solution to resize drawings from the windows team bc their WILL SDK doesn't save size
            newSize.width = 650
            newSize.height = 650
        }
    
        return Float(self.frame.size.width / newSize.width)
    }
    
    func refreshViewWithElements(elements: [AnyObject], atSize size: CGSize) -> [AnyObject] {
        var scaledElements: [AnyObject] = []
        
        for element in elements {
            let scaleFactor = determineScaleFactor(originalSize: size)
            if let strokeElement = element as? Stroke {
                let scaledVector = scaleStrokeVector(
                    vector: strokeElement.points.copy(),
                    atScaleFactor: scaleFactor
                )
                strokeRenderer.resetAndClearBuffers()
                strokeRenderer.drawPoints(scaledVector.pointer(), finishStroke: true)
                strokeRenderer.blendStroke(in: strokesLayer, with: strokeElement.blendMode)
                scaledElements.append(Stroke(points: scaledVector, andStride: strokeElement.stride, andWidth: strokeElement.width, andColor: strokeElement.color, andTs: strokeElement.ts, andTf: strokeElement.tf, andBlendMode: strokeElement.blendMode))
            }
            else if let messageImageElement = element as? DraggableImageView {
                let imageElement = DraggableImageView(image: messageImageElement.image!)
                imageElement.isUserInteractionEnabled = shouldDraw
                imageElement.frame = CGRect(origin: CGPoint(x: messageImageElement.frame.origin.x * CGFloat(scaleFactor),
                                                            y: messageImageElement.frame.origin.y * CGFloat(scaleFactor)),
                                            size: CGSize(width: messageImageElement.frame.width * CGFloat(scaleFactor),
                                                         height: messageImageElement.frame.height * CGFloat(scaleFactor)))
                scaledElements.append(imageElement)
                self.addSubview(imageElement)
            }
            else if let messageTextElement = element as? DraggableTextView {
                let textViewElement = DraggableTextView(frame: CGRect(origin: CGPoint(x: messageTextElement.frame.origin.x * CGFloat(scaleFactor),
                                                                                      y: messageTextElement.frame.origin.y * CGFloat(scaleFactor)),
                                                                      size: CGSize(width: messageTextElement.frame.width * CGFloat(scaleFactor),
                                                                                   height: messageTextElement.frame.height * CGFloat(scaleFactor))))
                textViewElement.text = messageTextElement.text
                textViewElement.isUserInteractionEnabled = shouldDraw
                scaledElements.append(textViewElement)
                self.addSubview(textViewElement)
            }
            else {
                print("Not expecting this type")
            }
        }
        
        refreshViewInRect(rect: viewLayer.bounds)
        return scaledElements
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.processTouches(touches: touches, withEvent: event!)
        self.endEditing(true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.processTouches(touches: touches, withEvent: event!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.processTouches(touches: touches, withEvent: event!)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.processTouches(touches: touches, withEvent: event!)
    }
}
