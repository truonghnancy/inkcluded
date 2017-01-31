//
//  DrawView.m
//  WillDemo
//
//  Created by Josh Choi on 1/22/17.
//  Copyright © 2017 Josh Choi. All rights reserved.
//

#import "DrawView.h"
#import "Stroke.h"
#import <WILLCore/WILLCore.h>

@implementation DrawView
{
    WCMRenderingContext * willContext;
    
    WCMLayer* viewLayer;
    
    WCMStrokeRenderer * strokeRenderer;
    
    WCMSpeedPathBuilder * pathBuilder;
    
    WCMMultiChannelSmoothener * pathSmoothener;
    
    NSMutableArray * strokes;
    
    int pathStride;
}

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

-(id) initWithFrame:(CGRect)frame
{
    strokes = [NSMutableArray array];
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initWillContext];
        
        [self refreshViewInRect:viewLayer.bounds];
    }
    return self;
}

- (void) initWillContext
{
    if (!willContext)
    {
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        EAGLContext* eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!eaglContext || ![EAGLContext setCurrentContext:eaglContext])
        {
            NSLog(@"Unable to create EAGLContext!");
            return;
        }
        
        willContext = [WCMRenderingContext contextWithEAGLContext:eaglContext];
        
        viewLayer = [willContext layerFromEAGLDrawable:(id<EAGLDrawable>)self.layer withScaleFactor:self.contentScaleFactor];
        
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

-(void) refreshViewInRect:(CGRect)rect
{
    [willContext setTarget:viewLayer andClipRect:rect];
    [willContext clearColor:[UIColor whiteColor]];
    
    [strokeRenderer blendStrokeUpdatedAreaInLayer:viewLayer withBlendMode:WCMBlendModeNormal];
    
    [viewLayer present];
}

- (void) processTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    
    if (touch.phase != UITouchPhaseStationary)
    {
        CGPoint location = [touch locationInView:self];
        
        WCMInputPhase wcmInputPhase;
        
        if (touch.phase == UITouchPhaseBegan)
        {
            wcmInputPhase = WCMInputPhaseBegin;
            
            [pathSmoothener reset];
        }
        else if (touch.phase == UITouchPhaseMoved)
        {
            wcmInputPhase = WCMInputPhaseMove;
        }
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
        
        if (wcmInputPhase == WCMInputPhaseEnd)
        {
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


- (void) saveStrokes
{
    WCMInkEncoder * inkEncoder = [[WCMInkEncoder alloc] init];
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
