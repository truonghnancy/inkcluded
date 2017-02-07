//
//  DrawView.m
//  inkluded-405
//
//  Created by Josh Choi on 1/22/17.
//  Copyright © 2017 Josh Choi. All rights reserved.
//

#import "DrawView.h"
#import "Stroke.h"
#import <WILLCore/WILLCore.h>

@implementation DrawView
{
    // Renderer of layers
    WCMRenderingContext * willContext;
    
    // The main viewable layer
    WCMLayer* viewLayer;
    
    // Strokes layer
    WCMLayer * strokesLayer;
    
    // Renderer of all the layers
    WCMStrokeRenderer * strokeRenderer;
    
    // Helps build the path of strokes
    WCMSpeedPathBuilder * pathBuilder;
    
    // Help smooth out the paths
    WCMMultiChannelSmoothener * pathSmoothener;
    
    // Path brush for redrawing strokes
    WCMStrokeBrush * pathBrush;
    
    // Array of all the strokes
    NSMutableArray * strokes;
    
    // Stride of the brush, for redrawing
    int pathStride;
}

// The layer class that is being wrapped by the WILL framework
+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

/**
 * Constructor that creates a view based on the a given size
 *
 * @param frame the size to initialize the view to
 * @return the DrawView object
 **/
-(id) initWithFrame:(CGRect)frame
{
    strokes = [NSMutableArray array];
    self = [super initWithFrame:frame];
    // checks if the UIView was successfully created
    if (self)
    {
        [self initWillContext];
        [willContext setTarget:strokesLayer];
        [willContext clearColor:[UIColor clearColor]];
        
        [self refreshViewInRect:viewLayer.bounds];
    }
    return self;
}

/**
 * Initializes the DrawView resources with default initial values.  Initialize the resources for the DrawView to
 * successfully start drawing.
 *
 **/
- (void) initWillContext
{
    // checks if the renderer was not initialized yet
    if (!willContext)
    {
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        EAGLContext* eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        // Checks to make sure the EAGLContext was correctly constructed
        if (!eaglContext || ![EAGLContext setCurrentContext:eaglContext])
        {
            NSLog(@"Unable to create EAGLContext!");
            return;
        }
        
        willContext = [WCMRenderingContext contextWithEAGLContext:eaglContext];
        
        viewLayer = [willContext layerFromEAGLDrawable:(id<EAGLDrawable>)self.layer withScaleFactor:self.contentScaleFactor];
        
        strokesLayer = [willContext layerWithWidth:viewLayer.bounds.size.width andHeight:viewLayer.bounds.size.height andScaleFactor:viewLayer.scaleFactor andUseTextureStorage:YES];
        
        pathBrush = [willContext solidColorBrush];
        
        pathBuilder = [[WCMSpeedPathBuilder alloc] init];
        [pathBuilder setNormalizationConfigWithMinValue:0 andMaxValue:7000];
        [pathBuilder setPropertyConfigWithName:WCMPropertyNameWidth andMinValue:2 andMaxValue:15 andInitialValue:NAN andFinalValue:NAN andFunction:WCMPropertyFunctionPower andParameter:1 andFlip:NO];
        
        pathStride = [pathBuilder calculateStride];
        
        pathSmoothener = [[WCMMultiChannelSmoothener alloc] initWithChannelsCount:pathStride];
        
        strokeRenderer =  [willContext  strokeRendererWithSize:viewLayer.bounds.size andScaleFactor:viewLayer.scaleFactor];
        
        strokeRenderer.brush = [willContext solidColorBrush];
        strokeRenderer.stride = pathStride;
        strokeRenderer.color = [UIColor blackColor];
    }
}

/**
 * Refreshes the DrawView to correctly show the layers. Updates
 * the viewLayer.
 *
 * @param rect The area to update
 **/
-(void) refreshViewInRect:(CGRect)rect
{
    [willContext setTarget:viewLayer andClipRect:rect];
    [willContext clearColor:[UIColor whiteColor]];
    
    [willContext drawLayer:strokesLayer withSourceRect:rect andDestinationRect:rect andBlendMode:WCMBlendModeNormal];
    [strokeRenderer blendStrokeUpdatedAreaInLayer:viewLayer withBlendMode:WCMBlendModeNormal];
    
    [viewLayer present];
}

/**
 * Processes touches on the DrawView.  Constantly called whenever the DrawView is touched.
 * Creates strokes and and the end of a series touches, saves the touches as a single stroke.
 *
 * @param touches a representation of the touch
 * @param event unused so far
 **/
- (void) processTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    
    // Check if the touches are not moving
    if (touch.phase != UITouchPhaseStationary)
    {
        CGPoint location = [touch locationInView:self];
        
        WCMInputPhase wcmInputPhase;
        
        // If the touches have just started
        if (touch.phase == UITouchPhaseBegan)
        {
            wcmInputPhase = WCMInputPhaseBegin;
            
            [pathSmoothener reset];
        }
        // If the touches have begun moving again
        else if (touch.phase == UITouchPhaseMoved)
        {
            wcmInputPhase = WCMInputPhaseMove;
        }
        // The touches have stopped, pen is off the canvas.
        else if (touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled)
        {
            wcmInputPhase = WCMInputPhaseEnd;
        }
        
        WCMFloatVectorPointer * points = [pathBuilder addPointWithPhase:wcmInputPhase andX:location.x andY:location.y andTimestamp:touch.timestamp];
        WCMFloatVectorPointer * smoothedPoints = [pathSmoothener smoothValues:points reachFinalValues:wcmInputPhase == WCMInputPhaseEnd];
        WCMPathAppendResult* pathAppendResult = [pathBuilder addPathPart:smoothedPoints];
        
        WCMFloatVectorPointer * prelimPoints = [pathBuilder createPreliminaryPath];
        WCMFloatVectorPointer * smoothedPrelimPoints = [pathSmoothener smoothValues:prelimPoints reachFinalValues:YES];
        WCMFloatVectorPointer * prelimPath = [pathBuilder finishPreliminaryPath:smoothedPrelimPoints];
        
        [strokeRenderer drawPoints:pathAppendResult.addedPath finishStroke:wcmInputPhase == WCMInputPhaseEnd];
        [strokeRenderer drawPreliminaryPoints:prelimPath];
        
        [self refreshViewInRect:strokeRenderer.updatedArea];
        
        // Check to see if all inputs from a single stroke have stopped to store that single stroke, pen is off canvas.
        if (wcmInputPhase == WCMInputPhaseEnd)
        {
            [strokeRenderer blendStrokeInLayer:strokesLayer withBlendMode:WCMBlendModeNormal];
            
            Stroke* stroke = [Stroke strokeWithPoints:[WCMFloatVector vectorWithBegin:pathAppendResult.wholePath.begin andEnd:pathAppendResult.wholePath.end]
                                            andStride:pathStride
                                             andWidth:NAN
                                             andColor:[UIColor blackColor]
                                                andTs:0
                                                andTf:1
                                         andBlendMode:WCMBlendModeNormal];
            [strokes addObject:stroke];
        }
    }
    
    
}

/**
 * Saves strokes of this current DrawView.  Currently creates the will doc, may need to be
 * changed in the future once other layers are added so only 1 doc is created and that
 * one doc is consistently updated. The default will doc path is:
 * /Users/<USER>/Library/Developer/CoreSimulator/Devices/<SIMULATOR-ID>/data/Containers/Data/Application/<APP-ID>/Documents/
 *
 **/
- (void) saveStrokes
{
    WCMInkEncoder * inkEncoder = [[WCMInkEncoder alloc] init];
    
    // For every stroke in strokes, we will encode that strokes attributes.
    for (Stroke * s in strokes)
    {
        [inkEncoder encodePathWithPrecision:2 andPoints:s.points andStride:s.stride andWidth:s.width andColor:s.color andTs:0 andTf:1 andBlendMode:WCMBlendModeNormal];
    }
    
    NSData * inkData = [inkEncoder getBytes];
    
    WCMDocument * doc = [[WCMDocument alloc] init];
    
    WCMDocumentSection * section = [[WCMDocumentSection alloc] init];
    section.size = self.bounds.size;
    
    WCMDocumentSectionPaths * pathsElement = [[WCMDocumentSectionPaths alloc] init];
    [pathsElement.content setData:inkData withType:[WCMDocumentContentType STROKES]];
    
    [doc.sections addObject:section];
    [section addElement:pathsElement];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *willDocPath = [documentsPath stringByAppendingPathComponent:@"document.will"];
    
    [doc createDocumentAtPath:willDocPath];
}

/**
 * Decode all the strokes from the default will doc path.  May also need to be changed to
 * handle extra layers and resources that the will doc will store.  The default will doc
 * path is: 
 * /Users/<USER>/Library/Developer/CoreSimulator/Devices/<SIMULATOR-ID>/data/Containers/Data/Application/<APP-ID>/Documents/
 *
 **/
- (void) decodeStrokesFromDocumentPath
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"document.will"];
    
    WCMDocument * doc = [[WCMDocument alloc] init];
    
    [doc loadDocumentAtPath:path];
    
    WCMDocumentSection * section = doc.sections[0];
    WCMDocumentSectionPaths * pathsElement = section.subelements[0];
    NSData * inkData = [pathsElement.content loadData];
    
    WCMInkDecoder * decoder = [[WCMInkDecoder alloc] initWithData:inkData];
    
    WCMFloatVector* strokePoints;
    unsigned int strokeStride;
    float strokeWidth;
    UIColor* strokeColor;
    float strokeStartValue;
    float strokeFinishValue;
    WCMBlendMode blendMode;
    
    strokes = [[NSMutableArray alloc] init];
    
    // While there are still strokes in the will doc to draw, we will continue adding strokes.
    while([decoder decodePathToPoints:&strokePoints
                            andStride:&strokeStride
                             andWidth:&strokeWidth
                             andColor:&strokeColor
                                andTs:&strokeStartValue
                                andTf:&strokeFinishValue
                         andBlendMode:&blendMode])
    {
        Stroke * stroke = [Stroke strokeWithPoints:strokePoints
                                         andStride:strokeStride
                                          andWidth:strokeWidth
                                          andColor:strokeColor
                                             andTs:strokeStartValue
                                             andTf:strokeFinishValue
                                      andBlendMode:blendMode];
        [strokes addObject:stroke];
    }
    
    [willContext setTarget:strokesLayer];
    [willContext clearColor:[UIColor clearColor]];
    
    WCMStrokeRenderer * renderer = [willContext strokeRendererWithSize:viewLayer.bounds.size andScaleFactor:viewLayer.scaleFactor];
    renderer.brush = pathBrush;
    
    // For every stroke in strokes, we will render it to the strokesLayer.
    for (Stroke * s in strokes)
    {
        renderer.stride = s.stride;
        renderer.width = s.width;
        renderer.color = s.color;
        renderer.ts = s.ts;
        renderer.tf = s.tf;
        
        [renderer resetAndClearBuffers];
        [renderer drawPoints:s.points.pointer finishStroke:YES];
        [renderer blendStrokeInLayer:strokesLayer withBlendMode:s.blendMode];
    }
    
    [self refreshViewInRect:viewLayer.bounds];
    
}

/**
 * The next 4 functions are immediately called when the DrawView is touched.
 *
 **/

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self processTouches:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self processTouches:touches withEvent:event];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self processTouches:touches withEvent:event];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self processTouches:touches withEvent:event];
}

@end
