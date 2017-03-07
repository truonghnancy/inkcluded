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
    
    override init(frame: CGRect) {
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
        
        if (touch.phase != UITouchPhase.stationary) {
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
    
    func refreshViewWithElements(elements: [AnyObject]) {
        for element in elements {
            if let strokeElement = element as? Stroke {
                strokeRenderer.resetAndClearBuffers()
                strokeRenderer.drawPoints(strokeElement.points.pointer(), finishStroke: true)
                strokeRenderer.blendStroke(in: strokesLayer, with: strokeElement.blendMode)
            }
            else if let imageElement = element as? DraggableImageView {
                self.addSubview(imageElement)
            }
            else if let textViewElement = element as? DraggableTextView {
                self.addSubview(textViewElement)
            }
            else {
                print("Not expecting this type")
            }
        }
        
        refreshViewInRect(rect: viewLayer.bounds)
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
