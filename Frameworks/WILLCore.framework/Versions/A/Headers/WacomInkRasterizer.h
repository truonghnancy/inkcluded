//
//  WacomInkRasterizer.h
//  WacomInk
//
//  Created by Plamen Petkov on 2/14/14.
//  Copyright (c) 2014 Wacom. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "WacomInkConfig.h"
#import "WacomInkUtil.h"

/**
 Struct that represents a quadrilateral.
 */
typedef struct {
    
    CGPoint a;
    CGPoint b;
    CGPoint c;
    CGPoint d;
    
} WCMQuad;

/**
 Creates a quadrilateral from a CGRect.
 */
static inline WCMQuad WCMQuadMakeFromRect(CGRect rect)
{
    float left = CGRectGetMinX(rect);
    float bottom = CGRectGetMinY(rect);
    float right = CGRectGetMaxX(rect);
    float top = CGRectGetMaxY(rect);
    
    return (WCMQuad) {
        CGPointMake(left, bottom),
        CGPointMake(right, bottom),
        CGPointMake(left, top),
        CGPointMake(right, top)};
};

static inline WCMQuad WCMQuadApplyTransform(WCMQuad quad, CGAffineTransform transform)
{
    quad.a = CGPointApplyAffineTransform(quad.a, transform);
    quad.b = CGPointApplyAffineTransform(quad.b, transform);
    quad.c = CGPointApplyAffineTransform(quad.c, transform);
    quad.d = CGPointApplyAffineTransform(quad.d, transform);
    
    return quad;
}


@class WCMDirectStrokeBrush;
@class WCMSolidColorStrokeBrush;
@class WCMParticleStrokeBrush;

/**
 This class specifies how a stroke is going to be rendered. Instance of this class (or its sub-classes) is needed by the WCMStrokeRenderer when rendering a stroke.
 
 <b>NOTE: Instances of this class should NOT be created using alloc and init, but rather should be obtained from a WCMRenderingContext instance.</b>
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMStrokeBrush : NSObject

/** @name Creating a Brush */

/**
 @since 1.2
 @abstract Creates and returns initialized WCMStrokeBrush instance. Strokes draw with this brush will be filled with a solid color.
 @deprecated in 1.3. Use [WCMRenderingContext directBrush] instead. Notice that you should call [WCMRenderingContext directBrush], instead of [WCMRenderingContext solidColorBrush]! In 1.3 the solidColorBrush implementation was changed and the 1.2 implementation was renamed to directBrush.
 */
+ (WCMStrokeBrush*) solidColorBrush __attribute__ ((deprecated));

/**
 @since 1.2
 @abstract Creates and returns initialized WCMStrokeBrush instance with custom blend mode. Strokes draw with this brush will be filled with a solid color.
 @param blendMode Specifies the blend mode used.
 @deprecated in 1.3. Use [WCMRenderingContext directBrushWithBlendMode:] instead. In 1.3 the solidColorBrush implementation was changed and the 1.2 implementation was renamed to directBrush.
 */
+ (WCMStrokeBrush*) solidColorBrushWithBlendMode:(WCMBlendMode)blendMode __attribute__ ((deprecated));

/**
 @since 1.2
 @abstract Creates and returns initialized WCMStrokeBrush instance. Strokes with this brush will be drawn using a large number of small textures (called particles), scattered along the stroke's trajectory.
 @param fillTexture This image will fill the stroke. It will be repeated (tiled). Its dimension must be power of 2.
 @param shapeTexture This image used for each particle.
 @param spacing Defines the separation between particles. The value must be greater than 0. Value of 1.0 means that the distance between two particles will be equal the average width of the two particles.
 @param scattering Controls how much the particles will spread out sideways. Value of 0 means no spread out. Values of 1, means that each particle will be displaced sideways a random amount between 0% to 100% of its width.
 @param blendMode Specifies the blend mode with which each particle will be drawn.
 @param rotateAlongTrajectory This parameter tells whether or not each particle to be rotates in such a way that it follows the trajectory. If rotateRandom is set to YES, this parameter is ignored.
 @param rotateRandom This parameter tells whether or not each particle to be rotated randomly around its center. If set to YES, the rotateAlongTrajectory parameter will be ignored.
 @deprecated in 1.3 Use [WCMRenderingContext particleBrushWithFillImage: andShapeImage: andSpacing: andScattering: andBlendMode: andRotateAlongTrajectory: orRotateRandom:] instead.
 */
+ (WCMStrokeBrush*) particleBrushWithFillImage:(UIImage*)fillTexture
                                 andShapeImage:(UIImage*)shapeTexture
                                    andSpacing:(CGFloat)spacing
                                 andScattering:(CGFloat)scattering
                                  andBlendMode:(WCMBlendMode)blendMode
                      andRotateAlongTrajectory:(BOOL)rotateAlongTrajectory orRotateRandom:(BOOL)rotateRandom __attribute__ ((deprecated));

/**
 @since 1.2
 @abstract Creates and returns initialized WCMStrokeBrush instance. Strokes with this brush will be drawn using a large number of small textures (called particles), scattered along the stroke's trajectory. Instead of a single shape image, this method needs an array of images in different resolutions.
 @param fillTexture This image will fill the stroke. It will be repeated (tiled). Its dimensions must be power of 2.
 @param shapeTextureLevels Specifies several scale levels of the image used for each particle. You provide an array of images with different resolutions. The dimensions of each images must be a power of 2. The images must be provided in decreasing order of their dimensions. The dimensions of each image in the array must be exactly half of the dimensions of the previous one.
 @param spacing Defines the separation between particles. The value must be greater than 0. Value of 1.0 means that the distance between two particles will be equal the average width of the two particles.
 @param scattering Controls how much the particles will spread out sideways. Value of 0 means no spread out. Values of 1, means that each particle will be displaced sideways a random amount between 0% to 100% of its width.
 @param blendMode Specifies the blend mode with which each particle will be drawn.
 @param rotateAlongTrajectory This parameter tells whether or not each particle to be rotates in such a way that it follows the trajectory. If rotateRandom is set to YES, this parameter is ignored.
 @param rotateRandom This parameter tells whether or not each particle to be rotated randomly around its center. If set to YES, the rotateAlongTrajectory parameter will be ignored.
 @discussion Strokes with this brush will be drawn using a large number of small textures (particles), scattered along the stroke's trajectory.
 @deprecated Use [WCMRenderingContext particleBrushWithFillImage: andShapeMipmapLevelsImages: andSpacing: andScattering: andBlendMode: andRotateAlongTrajectory: orRotateRandom:] instead.
 */
+ (WCMStrokeBrush*) particleBrushWithFillImage:(UIImage*)fillTexture
                    andShapeMipmapLevelsImages:(NSArray*)shapeTextureLevels
                                    andSpacing:(CGFloat)spacing
                                 andScattering:(CGFloat)scattering
                                  andBlendMode:(WCMBlendMode)blendMode
                      andRotateAlongTrajectory:(BOOL)rotateAlongTrajectory orRotateRandom:(BOOL)rotateRandom __attribute__ ((deprecated));

/**
 @since 1.2
 @abstract Factor that specifies how much the brush will "spread out" perpendicular to the stroke direction. This property is included in the root of the WCMStrokeBrush hierarchy because is need for a proper calculations of the bounds of the stroke. Only objects of the WCMParticleStrokeBrush class could have a non zero value for it. For objects of the WCMSolidColorStrokeBrush and WCMDirectStrokeBrush classes the value will aways be 0.
 @discussion Value of 0 means that the stroke will not spread out, its width will always be equal the the specified width.
 Value of 1 means that the stroke will spread out 1 time its width, 2 means 2 times its width, etc.
 */
@property CGFloat scattering;

@end

/**
 Strokes draw with this brush will be filled with a solid color.
 Strokes drawn with this brush are guaranteed to be rendered correctly independent of paths drawn.
 Unlike the WCMDirectStrokeBrush, which is faster but could produce "glitches" for paths which vary sharply in width. This is the recommended brush for solid color strokes.
 
 <b>NOTE: Instances of this class should NOT be created using alloc and init, but rather should be obtained from a WCMRenderingContext instance.</b>
 
 @discussion This brush is designed to draw strokes in a dedicated layer. Later the content if that layer could be blended using a desired blend mode in another layer. The WCMStrokeRenderer class will handle the "two step" drawing process.
 
 @since 1.3
 */
WACOMINK_PUBLIC
@interface WCMSolidColorStrokeBrush: WCMStrokeBrush

@end

/**
 Strokes draw with this brush will be filled with a solid color.
 This brush is fast but unlike WCMSolidColorStrokeBrush, strokes drawn with it could have slight glitches for paths that vary sharply in width.
 It is recommended to use the WCMSolidColorStrokeBrush instead, unless you really need the performance gain and you will draw paths that have been smoothed out.
 
 <b>NOTE: Instances of this class should NOT be created using alloc and init, but rather should be obtained from a WCMRenderingContext instance.</b>
 
 @since 1.3
 */
WACOMINK_PUBLIC
@interface WCMDirectStrokeBrush : WCMStrokeBrush

/**
 @since 1.3
 @abstract Specifies the blend mode with which each segment will be drawn.
 */
@property WCMBlendMode blendMode;

@end

/**
 Strokes drawn with this brush will be drawn using a large number of small textures (called particles), scattered along the stroke's trajectory. This brush is much more computational heavy compared to the WCMSolidColorStrokeBrush but it allows to create visually expressive strokes.
 This brush will draw a large number of small images (defined by the shapeTextureId) along the stroke's path.
 Then they will be filled by repeating the image defined by the fillTexture.
 The distance between the particles is controlled by the spacing property. The value of the spacing must be greater than 0. Value of 1.0 means that the distance between two particles will be equal the average width of the two particles.
 The particles could also spread out sideways. This is controlled by the scattering property. Value of 0 means no spreading. Value of 1, means that the particles will spread out with a random amount between zero and one time of their width.
 The shape texture could be rotated randomly if the rotateRandom property is YES.
 Alternatively if the rotateRandom is NO and rotateAlongTrajectory YES, each particle will be rotated in such a way that it is oriented in the direction of the stroke.
 
 <b>NOTE: Instances of this class should NOT be created using alloc and init, but rather should be obtained from a WCMRenderingContext instance.</b>
 
 @since 1.3
 */
WACOMINK_PUBLIC
@interface WCMParticleStrokeBrush : WCMStrokeBrush

/**
 @since 1.3
 @abstract The OpenGL identifier of the fill texture. This property is useful if your are using WILL together with other OpenGL code.
 */
@property GLuint fillTextureId;

/**
 @since 1.3
 */
@property CGSize fillPatternSize;

/**
 @since 1.3
 @abstract The OpenGL identifier of the shape texture. This property is useful if your are using WILL together with other OpenGL code.
 */
@property GLuint shapeTextureId;

/**
 @since 1.3
 @abstract Defines the separation between particles. The value must be greater than 0. Value of 1.0 means that the distance between two particles will be equal the average width of the two particles.
 */
@property CGFloat spacing;

/**
 @since 1.3
 @abstract The blendMode specifies the blend mode with which each particle will be drawn.
 */
@property WCMBlendMode blendMode;

/**
 @since 1.3
 @abstract This parameter tells whether or not each particle to be rotated randomly around its center. If set to YES, the rotateAlongTrajectory parameter will be ignored.  This parameter tells whether or not each particle to be rotates in such a way that it follows the trajectory. If rotateRandom is set to YES, this parameter is ignored.
 */
@property WCMStrokeBrushRotation rotationMode;

@end

/**
 The WCMLayer class is a storage for graphics(pixels) that can be updated, drawn to other layers or presented on the screen. The layer are backed by an OpenGL texture or a renderBuffer. Only layers using a texture storage could be drawn in other layers. The benefit of layers using a renderBuffer is that reading the pixel data from them is faster. The layer has a scaleFactor that defines the ratio between the abstract layer dimensions and the actual size in pixels. It is much like the UIView's contentScaleFactor. In cases when a layer is displayed in a UIView, it is good idea to set the scaleFactor of the layer to be equal to the contentScaleFactor of the view.
 
 <b>NOTE: Instances of this class should NOT be created using alloc and init, but rather should be obtained from a WCMRenderingContext instance.</b>
 
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMLayer : NSObject

/**
 @since 1.2
 @abstract The width of the layer.
 */
@property (readonly) int width;

/**
 @since 1.2
 @abstract The height of the layer.
 */
@property (readonly) int height;

/**
 @since 1.2
 @abstract The scale of the layer.
 @discussion The scaleFactor defines the ratio between the abstract layer dimensions and the actual underlying pixels. It is much like UIView's contentScaleFactor and in the general case, when creating a layer for a view you set its scaleFactor to be the contentScaleFactor of the view.
 */
@property (readonly) float scaleFactor;

/**
 @since 1.2
 @abstract The *width* of the layer in pixels. Equals to width * scaleFactor.
 */
@property (readonly) int storageWidth;

/**
 @since 1.2
 @abstract The *height* of the layer in pixels. Equals to height * scaleFactor.
 */
@property (readonly) int storageHeight;

/**
 @since 1.2
 @abstract The bounds of the layer. Equals to (0, 0, width, height).
 */
@property (readonly) CGRect bounds;

/**
 @since 1.2
 @abstract The bounds of the layer in pixels. Equals to (0,0, storageWidth, storageHeight).
 */
@property (readonly) CGRect storageBounds;

/**
 @since 1.2
 @abstract Wether or not the layer stores its pixels as an OpenGL texture or in renderBuffer. Only layers using texture storage could be drawn in other layers.
 @discussion If value is YES, the layer is backed up by an OpenGL texture. Those kind of layers could be drawn in other layers. On the other hand a layer backed by a renderBuffer could be associated with an UIView. Those kind of layers could be displayed on the screen. Also reading the pixels from a layers backed by renderBuffer should be faster.
 */
@property (readonly) BOOL useTextureStorage;

/**
 @since 1.2
 @abstract The identifier of the OpenGL framebuffer.
 */
@property (readonly) GLuint frameBufferId;

/**
 @since 1.2
 @abstract The identifier of the OpenGL texture. Equals to 0 if the layer uses a render buffer as a storage.
 */
@property (readonly) GLuint textureId;

/**
 @since 1.2
 @abstract The identifier of the OpenGL renderbuffer. Equals to 0 if the layer uses a texture as a storage.
 */
@property (readonly) GLuint renderBufferId;

/**
 @since 1.3
 @abstract Returns a new rectangle that contains the original one, and is snapped to exact pixel of the underlying storage (texture or render buffer). The result is also constrained in the bounds of the layer.
 
 This method is useful when drawing a layer with the [WCMRenderingContext drawLayer:withSourceRect:andDestinationRect:andBlendMode:] with conjecture with the [WCMRenderingContext setTargetClipRect:] method, that sets the clipRect to be the destinationRect. Because the the [WCMRenderingContext setTargetClipRect:] always snaps to exact pixel (it is implemented using the the OpenGL's glScissor), it is good idea to snap the destinationRect using this method. Otherwise there could be 1px line at the borders of the rect left unfilled of filled partially.
 
 @param rect The rectangle that will be snapped to exact pixel.
 
 @return A new rectangle that contains the original one, and is snapped to exact pixel of the underlying storage (texture or render buffer). The result is also constrained in the bounds of the layer.
 */
-(CGRect) cgRectSnapToPixel:(CGRect)rect;

/**
 @since 1.2
 @abstract Request the native window system display the OpenGL ES renderbuffer associated with this layer. For layers backed up by a texture, this method will have no offset.
 @discussion This method will bind renderbuffer baking this layer and then call presentRenderbuffer: of the associated EAGLContext.
 */
-(void) present;

@end


/**
 The WCMStrokeRenderer class provides an mechanism to draw strokes on an WCMLayer.
 It encapsulates dirty area clean-up and rendering optimization techniques, which allow fast and smooth stroke drawing.
 If the stroke's path parts are being smoothened during the stroke generation using the WCMMultiChannelSmoothener class,
 some lag occurs because of the the way the smoothing algorithm works. Because of that the WCMStrokeRenderer supports
 preliminary stroke curves, which can be drawn to fix the added lag.
 
 The WCMStrokeRenderer class uses two-step approach:
 First a set of points are being drawn using the <[WCMStrokeRenderer drawPoints:finishStroke:]> method. This method can be called multiple times.
 Then, if a preliminary curve should also be displayed, the [WCMStrokeRenderer drawPreliminaryPoints:] method should be called.
 All changes currently made are being applied to an internally maintained layer (or layers if the [WCMStrokeRenderer drawPreliminaryPoints:] is called) of the WCMStrokeRenderer instance and no visual effect can be observed yet.
 On the second step of the drawing process the changes should be present to the screen (or to an offscreen layer). For that purpose the newly generated stroke part should be blended to a user defined destination layer using the [WCMStrokeRenderer blendStrokeInLayer:withBlendMode:] or [WCMStrokeRenderer blendStrokeUpdatedAreaInLayer:withBlendMode:] methods. The firs method will blend the whole stroke, while the second one will blend only the area which encloses the parts produced by the [WCMStrokeRenderer drawPoints:finishStroke:] and [WCMStrokeRenderer drawPreliminaryPoints:] methods, that have not been blended yet.
 
 The WCMStrokeRenderer also provides methods to retrieve the last updated stroke area and the total stroke area.
 The class also holds the stroke configuration like its brush, color, stride, width, etc.
 
 When we are done with a stroke (or before starting a new one), we should call the [WCMStrokeRenderer resetAndClearBuffers]. The method will clear the internal stroke buffer layer.
 
 <b>NOTE: Instances of this class should NOT be created using alloc and init, but rather should be obtained from a WCMRenderingContext instance.</b>
 
 @since 1.3
 */
WACOMINK_PUBLIC
@interface WCMStrokeRenderer : NSObject

/**
 @since 1.3
 @abstract Instance of the WCMStrokeBrush class that determines how the stroke is going to be rendered.
 */
@property WCMStrokeBrush * brush;

/**
 @since 1.3
 @abstract The color of the strokes drawn.
 */
@property UIColor * color;

/**
 @since 1.3
 @abstract Seed for the random number generator used for the stroke rendering. This parameter is relevant only for strokes drawn with particle brush. The stroke will look exactly the same every time you draw it with the same rngSeed. When a new instance of the WCMStrokeRenderer class is created, the rngSeed is set using the C function time().
 */
@property uint32_t rngSeed;

/**
 @since 1.3
 @abstract The stride of the control points drawn by the [WCMStrokeRenderer drawPoints:finishStroke:] and [WCMStrokeRenderer drawPreliminaryPoints:] methods. That is the offset from one control point to the next. See [WCMAbstractPathBuilder calculateStride].
 */
@property int stride;

/**
 @since 1.3
 @abstract The width of the stroke. If the stroke has a variable width which is included in the control points array, this parameter must be NAN. The default value is NAN.
 */
@property float width;

/**
 @since 1.3
 @abstract The starting value for the Catmull-Rom spline parameter of the first curve of spline. The default value is 0.
 */
@property float ts;

/**
 @since 1.3
 @abstract The final value for the Catmull-Rom spline parameter of the last curve of the spline. The default value is 1.
 */
@property float tf;

/**
 @since 1.3
 @abstract Clears the internal stroke bufferLayer layer (the bufferPreliminaryLayer layer will not be cleared for performance reasons, but the state will be reset as if the preliminary points were not drawn). The method will also set the updatedArea and strokeBounds properties to CGRectNull. The typical usage is to call this method before drawing a new stroke.
 */
-(void) resetAndClearBuffers;

/**
 @abstract Resize the bufferPreliminaryLayer and the bufferPreliminaryLayer with the size specified.
 @param size The new size of the bufferPreliminaryLayer and bufferPreliminaryLayer.
 @since 1.5
 */
-(void) resizeBuffers:(CGSize)size;

/**
 @abstract When a preliminary curve is drawn, the content of the bufferLayer is copied to the bufferPreliminaryLayer. When this flag is set to NO (the default value), only the area that has been changed by the drawPoints: method will be copied. When this flag is set to YES all of the content of the  bufferLayer will be copied to the bufferPreliminaryLayer.
 */
@property BOOL copyAllToPreliminaryLayer;

/**
 @since 1.3
 @abstract Draws more points of the stroke.
 @param points Pointer to the control points array. Its size must be multiple of the stride set.
 @param finishStroke Whether or not this is the last points of the stroke.
 */
-(void) drawPoints:(WCMFloatVectorPointer*)points finishStroke:(BOOL)finishStroke;

/**
 @since 1.3
 @abstract Draws a preliminary curve for the current stroke. If the stroke's path parts are being smoothened during the stroke generation using the WCMMultiChannelSmoothener class,
 some lag occurs because of the the way the smoothing algorithm works. This method is designed to fix this issue.
 @param points Pointer to the control points array. Its size must be multiple of the stride set.
 */
-(void) drawPreliminaryPoints:(WCMFloatVectorPointer*)points;

/**
 @since 1.3
 @abstract Blends the whole stroke that was drawn in a desired layer with the blendMode specified.
 @param targetLayer Instance of the WCMLayer class in which we want the blend the stroke.
 @param blendMode The blend mode used.
 */
-(void) blendStrokeInLayer:(WCMLayer*)targetLayer withBlendMode:(WCMBlendMode)blendMode;

/**
 @since 1.3
 @abstract Blends the area of the stroke that was drawn but was not yet blended in a desired layer with the blendMode specified.
 @param targetLayer Instance of the WCMLayer class in which we want the blend the stroke.
 @param blendMode The blend mode used.
 */
-(void) blendStrokeUpdatedAreaInLayer:(WCMLayer*)targetLayer withBlendMode:(WCMBlendMode)blendMode;

/**
 @since 1.3
 @abstract Reference of the internal layers that store the stroke. This property is for advanced usages, in most cases you should not used it. One possible use case is to change the bufferLayer with another layer. You have to keep in mind that the bufferLayer and bufferPreliminaryLayer must have the same sizes and scaleFactors.
 */
@property WCMLayer * bufferLayer;

/**
 @since 1.3
 @abstract Reference of the internal layers that store the stroke's preliminary part. This property is for advanced usages, in most cases you should not used it. One possible use case is to change the bufferPreliminaryLayer with another layer. You have to keep in mind that the bufferLayer and bufferPreliminaryLayer must have the same sizes and scaleFactors.
 */
@property WCMLayer * bufferPreliminaryLayer;

/**
 @since 1.3
 @abstract The bounds of the hole stroke. Updated every time [WCMStrokeRenderer drawPoints:finishStroke:] is called. This property could be updated if you need the [WCMStrokeBrush blendStrokeInLayer: withBlendMode:] method to blend different (most likely bigger) area.
 
 */
@property CGRect strokeBounds;

/**
 @since 1.3
 @abstract The area that encloses the parts of the stroke that were drawn but are not blended yet by the [WCMStrokeRenderer blendStrokeUpdatedAreaInLayer:withBlendMode:] method. After the blend method is called the updatedArea will be reset on the next call of the [WCMStrokeRenderer drawPoints:finishStroke:] method. This property could be updated if you need the [WCMStrokeBrush blendStrokeUpdatedAreaInLayer: withBlendMode:] method to blend different (most likely bigger) area.
 */
@property CGRect updatedArea;

/**
 @abstract TODO: document
 @since 1.5
 */
@property CGRect clipRect;

@end


/**
 The WCMRenderingContext class is a graphics context that is used to render visual objects like strokes and layers, to fill paths and others. It has some similarity with the Quartz 2D's CGContext. It is build on top of OpenGL ES and acts as a wrapper of a *EAGLContext*. The destination of draw operations is always a instance of the WCMLayer class. This class is also responsible for creating an initializing instances of the WCMLayer class. A WCMLayer could represent the screen, a texture or an offscreen render buffer.
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMRenderingContext : NSObject

#pragma mark - Creating a Rendering Context
/** @name Creating a Rendering Context */

/**
 @since 1.2
 @abstract Creates and returns a rendering context, initialized with an instance of the *EAGLContext* class.
 @param eaglContext The EAGLContext instance associated with the rendering context. All OpengGL operations and resources (like textures or render buffers) will be for this context.
 @return an initialized instance of the WCMRenderingContext class.
 */
+(WCMRenderingContext*) contextWithEAGLContext:(EAGLContext*)eaglContext;

#pragma mark - Initializing a Rendering Context
/** @name Initializing a Rendering Context */

/**
 Initializes a newly allocated WCMRenderingContext with a EAGLContext.
 @param eaglContext The EAGLContext instance associated with the rendering context. All OpengGL operations and resources (like textures or render buffers) will be for this context.
 @return an initialized instance of the WCMRenderingContext class.
 */
-(id) initWithEAGLContext:(EAGLContext*)eaglContext;



#pragma mark - EAGLContext Access
/** @name EAGLContext Access */

/**
 @since 1.2
 @abstract Returns the EAGLContext instance associated with the rendering context. All OpenGL resources created by the rendering context belong the this EAGLContext.
 @return the EAGLContext instance associated with the rendering context.
 */
@property (readonly, strong) EAGLContext * eaglContext;


#pragma mark - Stroke Bruses
/** @name Creating a WCMStrokeBrush*/

/**
 @since 1.3
 @abstract Creates and returns initialized WCMStrokeBrush instance. Strokes draw with this brush will be filled with a solid color.
 Strokes drawn with this brush are guaranteed to be rendered correctly independent of paths drawn.
 Unlike the WCMDirectStrokeBrush, which is faster but could produce "glitches" for paths which vary sharply in width. This is the recommended brush for solid color strokes.
 @discussion This brush is designed to draw strokes in a dedicated layer. Later the content if that layer could be blended using a desired blend mode in another layer. The WCMStrokeRenderer class will handle the "two step" drawing process.
 */
- (WCMSolidColorStrokeBrush*) solidColorBrush;


/**
 @since 1.3
 @abstract Creates and returns initialized WCMStrokeBrush instance. Strokes draw with this brush will be filled with a solid color.
 This brush is fast but unlike WCMSolidColorStrokeBrush, strokes drawn with it could have glitches for paths that vary sharply.
 It is recommended to use the WCMSolidColorStrokeBrush instead, unless you really need the performance gain and you will draw smoothed out paths.
 */
- (WCMDirectStrokeBrush*) directBrush;

/**
 @since 1.3
 @abstract Creates and returns initialized WCMStrokeBrush instance with custom blend mode. Strokes draw with this brush will be filled with a solid color.
 This brush is fast but unlike WCMSolidColorStrokeBrush, strokes drawn with it could have glitches for paths that vary sharply.
 It is recommended to use the WCMSolidColorStrokeBrush instead, unless you really need the performance gain and you draw only smoothed out paths.
 @param blendMode Specifies the blend mode used.
 */
- (WCMDirectStrokeBrush*) directBrushWithBlendMode:(WCMBlendMode)blendMode;

/**
 @since 1.3
 @abstract Creates and returns initialized WCMStrokeBrush instance. Strokes drawn with this brush will be drawn using a large number of small textures (called particles), scattered along the stroke's trajectory.
 @param fillTexture This image will fill the stroke. It will be repeated (tiled). Its dimension must be power of 2.
 @param shapeTexture This image used for each particle.
 @param spacing Defines the separation between particles. The value must be greater than 0. Value of 1.0 means that the distance between two particles will be equal the average width of the two particles.
 @param scattering Controls how much the particles will spread out sideways. Value of 0 means no spread out. Values of 1, means that each particle will be displaced sideways a random amount between 0% to 100% of its width.
 @param blendMode Specifies the blend mode with which each particle will be drawn.
 @param rotationMode Specifies the rotation mode applied to each particle. See WCMStrokeBrushRotation.
 @discussion Strokes with this brush will be drawn using a large number of small textures (particles), scattered along the stroke's trajectory.
 */
- (WCMParticleStrokeBrush*) particleBrushWithFillImage:(UIImage*)fillTexture
                                         andShapeImage:(UIImage*)shapeTexture
                                            andSpacing:(CGFloat)spacing
                                         andScattering:(CGFloat)scattering
                                          andBlendMode:(WCMBlendMode)blendMode
                                           andRotation:(WCMStrokeBrushRotation)rotationMode;

/**
 @since 1.3
 @abstract Creates and returns initialized WCMStrokeBrush instance. Strokes with this brush will be drawn using a large number of small textures (called particles), scattered along the stroke's trajectory. Instead of a single shape image, this method needs an array of images in different resolutions.
 @param fillTexture After the stroke's shape (contour) is generated, it will be filled by tiling the image specified by this argument. The UIImage's size, determines the size of the tile. Its dimensions must be a power of 2. If you need to specify different size for the tile, use the [WCMRenderingContext particleBrushWithFillMipmapLevelsImages:andFillTileSize:andShapeMipmapLevelsImages:andSpacing:andScattering:andBlendMode:andRotation:] method instead.
 @param shapeTextureLevels Specifies several scale levels of the image used for each particle. You provide an array of images with different resolutions. The dimensions of each images must be a power of 2. The images must be provided in decreasing order of their dimensions. The dimensions of each image in the array must be exactly half of the dimensions of the previous one.
 @param spacing Defines the separation between particles. The value must be greater than 0. Value of 1.0 means that the distance between two particles will be equal the average width of the two particles.
 @param scattering Controls how much the particles will spread out sideways. Value of 0 means no spread out. Values of 1, means that each particle will be displaced sideways a random amount between 0% to 100% of its width.
 @param blendMode Specifies the blend mode with which each particle will be drawn.
 @param rotationMode Specifies the rotation mode applied to each particle. See WCMStrokeBrushRotation.
 @discussion Strokes with this brush will be drawn using a large number of small textures (particles), scattered along the stroke's trajectory.
 */
- (WCMParticleStrokeBrush*) particleBrushWithFillImage:(UIImage*)fillTexture
                            andShapeMipmapLevelsImages:(NSArray*)shapeTextureLevels
                                            andSpacing:(CGFloat)spacing
                                         andScattering:(CGFloat)scattering
                                          andBlendMode:(WCMBlendMode)blendMode
                                           andRotation:(WCMStrokeBrushRotation)rotationMode;

/**
 @since 1.3
 @abstract Creates and returns initialized WCMStrokeBrush instance. Strokes with this brush will be drawn using a large number of small textures (called particles), scattered along the stroke's trajectory. Instead of a single shape image, this method needs an array of images in different resolutions.
 @param fillTextureLevels Specifies several scale levels of the image used for tiling. After the stroke's shape (contour) is generated, it will be filled by tiling the image specified by this argument. The size of the tile is set by the fillTileSize argument. You provide an array of images with different resolutions. The dimensions of each images must be a power of 2. The images must be provided in decreasing order of their dimensions. The dimensions of each image in the array must be exactly half of the dimensions of the previous one.
 @param fillTileSize The size of the tile used to fill the stroke. The tile will be filled with content of the images defined by the fillTextureLevels.
 @param shapeTextureLevels Specifies several scale levels of the image used for each particle. You provide an array of images with different resolutions. The dimensions of each images must be a power of 2. The images must be provided in decreasing order of their dimensions. The dimensions of each image in the array must be exactly half of the dimensions of the previous one.
 @param spacing Defines the separation between particles. The value must be greater than 0. Value of 1.0 means that the distance between two particles will be equal the average width of the two particles.
 @param scattering Controls how much the particles will spread out sideways. Value of 0 means no spread out. Values of 1, means that each particle will be displaced sideways a random amount between 0% to 100% of its width.
 @param blendMode Specifies the blend mode with which each particle will be drawn.
 @param rotationMode Specifies the rotation mode applied to each particle. See WCMStrokeBrushRotation.
 @discussion Strokes with this brush will be drawn using a large number of small textures (particles), scattered along the stroke's trajectory.
 */
- (WCMParticleStrokeBrush*) particleBrushWithFillMipmapLevelsImages:(NSArray*)fillTextureLevels
                                                    andFillTileSize:(CGSize)fillTileSize
                                         andShapeMipmapLevelsImages:(NSArray*)shapeTextureLevels
                                                         andSpacing:(CGFloat)spacing
                                                      andScattering:(CGFloat)scattering
                                                       andBlendMode:(WCMBlendMode)blendMode
                                                        andRotation:(WCMStrokeBrushRotation)rotationMode;
/**
 @since 1.3
 @abstract Creates and returns initialized WCMParticleStrokeBrush instance using a WCMParticlePaint definition class instance.
 @param paint Instance of the WCMParticlePaint class used to initialized the instance.
 @return initialized WCMParticleStrokeBrush instance using a WCMParticlePaint definition class instance.
 */
- (WCMParticleStrokeBrush*) particleBrushWithPaint:(WCMParticlePaint*)paint;

#pragma mark - Creating a Stroke Renderer
/** @name Creating a WCMStrokeRenderer*/


/**
 @since 1.2
 @abstract Creates a stroke painter with width and height and scale factor.
 @param size The size of the internal layers created by the painter.
 @param scaleFactor The scale factor of the internal layers created by the painter.
 @return stroke painter with width and height and scale factor.
 */
-(WCMStrokeRenderer*) strokeRendererWithSize:(CGSize)size andScaleFactor:(CGFloat)scaleFactor;

/**
 @since 1.2
 @abstract Creates a stroke painter with existing WCMLayer as it s internal storage layer.
 @param strokeBufferLayer The layer that will be used for storing the stroke's pixel.
 @return a stroke painter with existing WCMLayer as it s internal storage layer.
 */
-(WCMStrokeRenderer*) strokeRenderertWithBufferLayer:(WCMLayer*)strokeBufferLayer;

/**
 @since 1.2
 @abstract Creates a stroke painter with existing WCMLayer's as it s internal storage layers.
 @param strokeBufferLayer The layer that will be used for storing the stroke's pixel.
 @param strokePreliminaryBufferLayer The layer that will be used for storing the stroke's preliminary curve pixels.
 @return a stroke painter with existing WCMLayer's as it s internal storage layers.
 */
-(WCMStrokeRenderer*) strokeRenderertWithBufferLayer:(WCMLayer*)strokeBufferLayer andPreliminaryBufferLayer:(WCMLayer*)strokePreliminaryBufferLayer;



#pragma mark - Creating a Layer
/** @name Creating a WCMLayer*/

/**
 @since 1.2
 @abstract Creates a layer with width and height. Scale factor of the layer is set to 1.0. The layer will use an OpenGL texture as a storage.
 @param width Layer's width. See [WCMLayer width].
 @param height Layer's height. See [WCMLayer height].
 @return layer with width and height. Scale factor of the layer is set to 1.0. The layer will use an OpenGL texture as a storage.
 */
-(WCMLayer*) layerWithWidth:(int)width andHeight:(int) height;

/**
 @since 1.2
 @abstract Creates a layer with width, height and scale factor. The layer will use a OpenGL texture as a storage. The layer will be filled with black color with alpha 0.
 @param width Layer's width. See [WCMLayer width].
 @param height Layer's height. See [WCMLayer height].
 @param scaleFactor Layer's scale factor. See [WCMLayer scaleFactor].
 @return layer with width, height and scaleFactor. The layer will use an OpenGL texture as a storage.
 */
-(WCMLayer*) layerWithWidth:(int)width andHeight:(int) height andScaleFactor:(int) scaleFactor;


/**
 @since 1.2
 @abstract Creates a layer with width, height and scaleFactor. Also specifies if the layer should will use texture or render buffer as a storage. The layer will be filled with black color with alpha 0.
 @param width Layer's width. See [WCMLayer width].
 @param height Layer's height. See [WCMLayer height].
 @param scaleFactor Layer's scale factor. See [WCMLayer scaleFactor].
 @param useTextureStorage Layer' use texture storage. See [WCMLayer useTextureStorage].
 @return layer with width, height and scaleFactor. Also specifies if the layer should will use texture or render buffer as a storage.
 @discussion If useTextureStorage is YES, the content will be stored in OpenGL texture. If useTextureStorage is NO, the content will be stored in OpenGL renderBuffer.
 */
-(WCMLayer*) layerWithWidth:(int)width andHeight:(int) height andScaleFactor:(int) scaleFactor andUseTextureStorage:(BOOL) useTextureStorage;


/**
 @since 1.2
 @abstract Creates a layer with width, height, scale factor and a combination of already created OpenGL resources - frameBuffer, renderBuffer or texture. The content of the renderBuffer or texture will NOT be changed in any way.
 @param width Layer's width. See [WCMLayer width].
 @param height Layer's height. See [WCMLayer height].
 @param scaleFactor Layer's scale factor. See [WCMLayer scaleFactor].
 @param framebufferId A frameBuffer identifier. If frameBuffer is set to 0, the layer could NOT be a target to a draw operation.
 @param renderbufferId A render-buffer identifier. Only one of the renderbufferId and textureId should be set (the other one should be 0).
 @param textureId A texture identifier. Only one of the renderbufferId and textureId should be set (the other one should be 0).
 @param ownGlResources If YES, when the layer is deallocated, the OpenGL resources (framebufferId, textureId, renderbufferId) will be deleted. If NO, the layer will not take responsibility for freeing the OpenGL resources.
 
 @return a layer with width, height, scale factor and a combination of already created OpenGL resources - frameBuffer, renderBuffer or texture.
 
 @discussion If a frameBuffer is set, the layer could be destination for rendering operations. If frameBuffer is set to 0, the layer could not be such destination. It could only be drawn in other layers.
 
 It is expected only one of the glRenderbufferId and textureId set (the other one should be set to 0).
 
 If ownGlResources is se to YES the Layer will delete the OpenGL resources when the instance is deallocated, otherwise the management of the OpenGL resources is a responsibility of the caller of the method.
 */
-(WCMLayer*) layerWithWidth:(int)width andHeight:(int) height andScaleFactor:(int) scaleFactor andGlFramebufferId:(unsigned int)framebufferId andGlRenderbufferId:(unsigned int)renderbufferId andGlTextureId:(unsigned int)textureId ownGlResources:(BOOL)ownGlResources;

/**
 @since 1.2
 @abstract Creates a layer associated with a EAGLDrawable. The layer will internally create a frameBuffer and a renderBuffer. The render buffer storage will be the EAGLDrawable. The size of the layer will be equal to the size of the EAGLDrawable divided by the scaleFactor (note that the storageWidth and storageHeight of the layer will always be equal to the EAGLDrawable's width and height).
 @param eaglDrawable The EAGLDrawable instance with which the layer will be associated.
 @param scaleFactor Layer's scale factor. See [WCMLayer scaleFactor].
 @return a layer associated with a EAGLDrawable. The layer will internally create a frameBuffer and a renderBuffer. The renderBuffer will associates with the EAGLDrawable. The size of the layer will be equal to the size of the EAGLDrawable divided by the scaleFactor. The layer will free the OpenGL resource when deallocated.
 */
- (WCMLayer*) layerFromEAGLDrawable:(id<EAGLDrawable>)eaglDrawable withScaleFactor:(float)scaleFactor;

/**
 @abstract Sets a new size of the layer using the size of the provided EAGLDrawable instance. You should call this method for layers created using the [WCMRenderingContext layerFromEAGLDrawable:withScaleFactor:], when the EAGLDrawable has changed its size.
 @param layer The layer that is going to be resized.
 @param eaglDrawable The EAGLDrawable used when the layer was created. It will determine the new size of the layer.
 @since 1.5
 */
- (WCMLayer*) resizeLayer:(WCMLayer*)layer withEAGLDrawable:(id<EAGLDrawable>)eaglDrawable;

/**
 @abstract Sets a new size of the layer. The underlying OpenGL texture or render buffer will be recreated with a new size. The content of the buffer(texture) will be undefined. You have the responsibility to set the content for the new size.
 @param layer The layer that is going to be resized.
 @param size The new size of the layer.
 @return The layer resized layer.
 @since 1.5
 */
- (WCMLayer*) resizeLayer:(WCMLayer *)layer withSize:(CGSize)size;

#pragma mark - Setting a Rendering Target
/** @name Setting a rendering target */

/**
 @since 1.2
 @abstract Sets the layer that will be the target of the rendering operations.
 @param layer The target layer
 */
-(void) setTarget:(WCMLayer*) layer;

/**
 @since 1.2
 @abstract Sets the layer that will be the target of the rendering operations. Also sets a clipping rect. The clipping rect corresponds to the OpenGL's glScissors function. The clipRect enables us block out the parts of the layer outside the rectangle, that we don’t to be affected by draw operations. Setting a smaller clipRect could also be performance optimization, when we know where we will draw.
 @param layer The layer to be set as current.
 @param clipRect The clipping rectangle to be set.
 */
-(void) setTarget:(WCMLayer*) layer andClipRect:(CGRect)clipRect;

/**
 @abstarct Returns the WCMLayer set by the [WCMRenderingContext setTarget:] or [WCMRenderingContext setTarget: andClipRect:] methods.
 @return The WCMLayer set by the [WCMRenderingContext setTarget:] or [WCMRenderingContext setTarget: andClipRect:] methods.
 */
-(WCMLayer*) currentTarget;


#pragma mark - Clear Color
/** @name Clear Color */

/**
 @since 1.2
 @abstract Clears the current target with a color specified by channels values. Channels are in the rage 0 to 1.
 @param red The red channel of the color. In the range 0 to 1.
 @param green The green channel of the color. In the range 0 to 1.
 @param blue The blue channel of the color. In the range 0 to 1.
 @param alpha The alpha channel of the color. In the range 0 to 1.
 @discussion Non-premultiplied colors are expected.
 */
-(void) clearColorWithRed:(float)red AndGreen:(float) green andBlue:(float) blue andAlpha:(float) alpha;


/**
 @since 1.2
 @abstract Clears the current target with a color specified by the color.
 @param color The color parameter.
 @discussion Non-premultiplied colors are expected.
 */
-(void) clearColor:(UIColor*) color;


#pragma mark - Manage the Clipping Rectangle
/** @name Manage the Clipping Rectangle */

/**
 @since 1.2
 @abstract Set a clipping rect of the current target. The clipping rect corresponds to the OpenGL's glScissors function. The clipRect enables us block out the parts of the layer outside the rectangle, that we don’t to be affected by draw operations. Setting a smaller clipRect could also be performance optimization, when we know where we will draw.
 @param clipRect The clipping rectangle to be set.
 @discussion This call will lead to a glScissor call. Note that this will be set only if the target is not changed. Every change of the target will disable the clipping rect.
 */
-(void) setTargetClipRect:(CGRect) clipRect;

/**
 @abstarct Returns the current clip rect set by the [WCMRenderingContext setTargetClipRect:] method.
 @return The current clip rect set by the [WCMRenderingContext setTargetClipRect:] method.
 */
-(CGRect) clipRect;

/**
 @since 1.2
 @abstract Disables the clipping rect. See [WCMRenderingContext setTargetClipRect:].
 @discussion This call will lead to glDisable of the GL_SCISSOR_TEST call.
 */
-(void) disableTargetClipRect;


#pragma mark - Draw Stroke
/** @name Draw Stroke */

/**
 @since 1.2
 @abstract Draws a stroke in the current target with the provided parameters. The method will check the bounds of each segment (the curve between two control points) against the clipRect set for this target. It will return the the bounding box of the stroke.
 @param brush Instance of the WCMStrokeBrush class that determines how the stroke is going to be rendered.
 @param controlPointsBeginning pointer to the control points array.
 @param bufferSize size of the control points array.
 @param stride stride of the control points buffer. That is the offset from one control point to the next.
 @param width The width of the stroke. If the stroke has a variable width which is included in the control points array, this parameter must be NAN.
 @param color The color of the stroke.
 @param roundCapBeginning Cap the stroke with a circle at the start.
 @param roundCapEnding Cap the stroke with a circle at the end.
 @return The bounding box of the stroke drawn.
 @deprecated This method very elaborate. The recommended way for drawing strokes in version 1.3 is to use an instance of the WCMStrokeRender class.
 */
-(CGRect) drawStrokeWithBrush:(WCMStrokeBrush*) brush andControlPointsBeginning:(float *) controlPointsBeginning andBufferSize:(size_t) bufferSize andStride:(int)stride andWidth:(float) width andColor:(UIColor*)color andRoundCapBeginning:(bool)roundCapBeginning andRoundCapEnding:(bool) roundCapEnding __attribute__ ((deprecated));;

/**
 @since 1.2
 @abstract Draws a stroke in the current target with the provided parameters. The method will check the bounds of each segment (the curve between two control points) against the clipRect set for this target. It will return the the bounding box of the stroke.
 @param brush Instance of the WCMStrokeBrush class that determines how the stroke is going to be rendered.
 @param controlPointsBeginning pointer to the control points array.
 @param bufferSize size of the control points array.
 @param stride stride of the control points buffer. That is the offset from one control point to the next.
 @param width The width of the stroke. If the stroke has a variable thickness which is included in the control points array, this parameter must be NAN.
 @param color The color of the stroke.
 @param roundCapBeginning Cap the stroke with a circle at the start.
 @param roundCapEnding Cap the stroke with a circle at the end.
 @param ts The starting value for the Catmull-Rom spline parameter of the first curve of spline (0 is the default value).
 @param tf The final value for the Catmull-Rom spline parameter of the last curve of the spline (1 is the default value).
 @param lastParticle Pointer the last rendered particle. This parameter is relevant only for strokes drawn with particle brush. Upon completion it will store the position and with of the last drawn particle. This way you are able to draw a single stroke with several successive draw calls. Each draw call will continue from state (particle position and width) at which the previous draw call finished. You can pass *NULL*.
 @param randomGeneratorSeed Seed for the random number generator used for the stroke rendering. This parameter is relevant only for strokes drawn with particle brush. The stroke will look exactly the same every time you draw it with the same randomGeneratorSeed. If you pass *NULL* a new seed will be generated automatically.
 @return The bounding box of the stroke drawn.
 @deprecated This method very elaborate. The recommended way for drawing strokes in version 1.3 is to use an instance of the WCMStrokeRender class.
 */
-(CGRect) drawStrokeWithBrush:(WCMStrokeBrush*) brush andControlPointsBeginning:(float *) controlPointsBeginning andBufferSize:(size_t) bufferSize andStride:(int)stride andWidth:(float) width andColor:(UIColor*)color  andRoundCapBeginning:(bool)roundCapBeginning andRoundCapEnding:(bool) roundCapEnding andTs:(float) ts andTf:(float)tf andLastParticle:(WCMStrokePoint*) lastParticle andRandomSeed:(uint32_t*) randomGeneratorSeed __attribute__ ((deprecated));

/**
 @since 1.2
 @abstract Draws a stroke in the current target with the provided parameters.
 @param brush Instance of the WCMStrokeBrush class that determines how the stroke is going to be rendered.
 @param controlPointsBeginning pointer to the control points array.
 @param bufferSize size of the control points array.
 @param stride stride of the control points buffer. That is the offset from one control point to the next.
 @param width The width of the stroke. If the stroke has a variable thickness which is included in the control points array, this parameter must be NAN.
 @param color The color of the stroke.
 @param roundCapBeginning Cap the stroke with a circle at the start.
 @param roundCapEnding Cap the stroke with a circle at the end.
 @param ts The starting value for the Catmull-Rom spline parameter of the first curve of spline (0 is the default value).
 @param tf The final value for the Catmull-Rom spline parameter of the last curve of the spline (1 is the default value).
 @param lastParticle Pointer the last rendered particle. This parameter is relevant only for strokes drawn with particle brush. Upon completion it will store the position and with of the last drawn particle. This way you are able to draw a single stroke with several successive draw calls. Each draw call will continue from state (particle position and width) at which the previous draw call finished. You can pass *NULL*.
 @param randomGeneratorSeed Seed for the random number generator used for the stroke rendering. This parameter is relevant only for strokes drawn with particle brush. The stroke will look exactly the same every time you draw it with the same randomGeneratorSeed. If you pass *NULL* a new seed will be generated automatically.
 @param checkBounds If set to YES the renderer will check the bounds of each segment (the curve between two control points) agains the clipRect of the current rendering target. This could lead to a performance gain if big parts of the stroke are outside the clipRect. On the other hand, if you are certain that most of stroke lays inside the clipRect, it is better to set it to NO. Note that setting this to NO will cause the method to always return CGRectNull, because it will skip bounds calculation all together.
 @return The bounding box of the stroke drawn. <b>If checkBounds is set to NO, bounds calculation will be skipped and the method will always return CGRectNull.</b>
 @deprecated This method very elaborate. The recommended way for drawing strokes in version 1.3 is to use an instance of the WCMStrokeRender class.
 */
-(CGRect) drawStrokeWithBrush:(WCMStrokeBrush*) brush andControlPointsBeginning:(float *) controlPointsBeginning andBufferSize:(size_t) bufferSize andStride:(size_t)stride andWidth:(float) width andColor:(UIColor*)color  andRoundCapBeginning:(bool)roundCapBeginning andRoundCapEnding:(bool) roundCapEnding andTs:(float) ts andTf:(float)tf andLastParticle:(WCMStrokePoint*) lastParticle andRandomSeed:(uint32_t*) randomGeneratorSeed andCheckBounds:(BOOL)checkBounds __attribute__ ((deprecated));

#pragma mark - Fill Path
/** @name Fill Path */

/**
 @since 1.2
 @abstract Fills the interior of a path with a solid color. The path is defined by a list of Catmull-Rom spline control points. The path will be close automatically.
 
 @param controlPoints Pointer to the control points array.
 @param bufferSize Size of the control points array.
 @param stride Stride of the control points array. Stride is the distance between points beginnings.
 @param color The fill color.
 @param antiAliased Whether or not to anti-alias the edges of the path. Default value is NO. **If you set it to YES, due to implementation limitations, the path's filled area will blend correctly only when the target layer is cleared with black color.**
 */
-(void) fillPath:(float*)controlPoints andBufferSize:(size_t)bufferSize andStride:(int)stride andColor:(UIColor*)color andAntiAliased:(BOOL)antiAliased;


#pragma mark - Draw Layer
/** @name Draw Layer */

/**
 @since 1.2
 @abstract Draws the content of the layer into the current target layer.
 @param layer The layer to be drawn.
 @discussion The layer drawn must use a texture storage. The layer content is drawn at (0,0) with a normal blend mode.
 */
-(void) drawLayer:(WCMLayer*) layer;


/**
 @since 1.2
 @abstract Draws the content of the layer into the current target layer.
 @param layer The layer to be drawn.
 @param blendMode The blend mode used.
 @discussion The layer must use a texture storage. The layer content is drawn at (0,0)
 */
-(void) drawLayer:(WCMLayer*) layer withBlendMode:(WCMBlendMode)blendMode;

/**
 @since 1.2
 @abstract Draws the content of the layer into the current target layer.
 @param layer The layer to be drawn.
 @param blendMode The blend mode used.
 @param transform Transformation of the layer drawn.
 @discussion The layer must use a texture storage. The content is drawn transformed with the transform parameter.
 */
-(void) drawLayer:(WCMLayer*) layer withTransform:(CGAffineTransform*) transform andBlendMode:(WCMBlendMode)blendMode;

/**
 @since 1.2
 @abstract Draws the content of the layer into the current target layer.
 @param layer The layer to be drawn.
 @param blendMode The blend mode used.
 @param transform Transformation of the layer drawn.
 @param antiAliasedEdges Flag indicating whether or not to anti-alias the edges of the layer drawn. The anti-aliasing accomplished by drawing a thin gradient stripes going to alpha 0, along the edges.
 @discussion The layer must use a texture storage. The content is drawn transformed with the transform parameter.
 */
-(void) drawLayer:(WCMLayer*) layer withTransform:(CGAffineTransform*) transform andBlendMode:(WCMBlendMode)blendMode andAntiAliasedEdges:(BOOL)antiAliasedEdges;

/**
 @since 1.2
 @abstract Draws the content of the layer into the current target layer.
 @param layer The layer to be drawn.
 @param sourceRect Specifies a rectangular area from the drawn layer. Only that portion of the layer will be drawn. The rect will be transformed by sourceTransform parameter.
 @param sourceTransform Specifies an affine transformation applied to the sourceRect parameter.
 @param destinationRect Specifies a rectangular area from the target layer. The content of the tranformed sourceRect will be stretched so it fills the transformed destinationRect entirely.
 @param destinationTransform Specifies an affine transformation applied to the destinationRect parameter.
 @param blendMode The blend mode used.
 @param antiAliasedEdges Flag indicating whether or not to anti-alias the edges of the layer drawn. The anti-aliasing accomplished by drawing a thin gradient stripes going to alpha 0, along the edges.
 @discussion The layer must use a texture storage. The content is drawn transformed with the transform parameter.
 */
-(void) drawLayer:(WCMLayer*) layer withSourceRect:(CGRect)sourceRect andSourceTransform:(CGAffineTransform) sourceTransform andDestinationRect:(CGRect)destinationRect andDestinationTransform:(CGAffineTransform) destinationTransform andBlendMode:(WCMBlendMode)blendMode andAntiAliasedEdges:(BOOL)antiAliasedEdges;

/**
 @since 1.2
 @abstract Draws the content of the layer into the current target layer.
 @param layer The layer to be drawn.
 @param sourceRect Specifies a rectangular area from the drawn layer. Only that portion of the layer will be drawn.
 @param destinationRect Specifies a rectangular area from the target layer. The content of the sourceRect will be stretched so it fills the destinationRect entirely.
 @param blendMode The blend mode used.
 @discussion The layer must use a texture storage.
 */
-(void) drawLayer:(WCMLayer*) layer withSourceRect:(CGRect)sourceRect andDestinationRect:(CGRect) destinationRect andBlendMode:(WCMBlendMode) blendMode ;

/**
 @since 1.2
 @abstract Draws the content of the layer into the current target layer.
 @param layer The layer that is drawn.
 @param sourceQuad Specifies a quadrilateral area from the the drawn layer. Only that portion of the layer will be drawn. <b>The sourceQuad must be convex.</b>
 @param destinationQuad Specifies a quadrilateral area from the target layer. The content of the sourceQuad will be stretched so it fills the destinationQuad entirely. <b>The destinationQuad must be convex.</b>
 @param blendMode The blend mode used.
 @discussion The layer must use a texture storage.
 @deprecated in 1.3. This method could produce unexpected results in texture sampling when passing quadrilaterals that are not the result of affine transformation applied to a rectangle. It is suggested to use the [WCMRenderingContext drawLayer: withSourceRect: andSourceTransform: andDestinationRect: andDestinationTransform: andBlendMode: andAntiAliasedEdges:] instead.
 @since 1.2
 */
-(void) drawLayer:(WCMLayer*) layer withSourceQuad:(WCMQuad)sourceQuad andDestinationQuad:(WCMQuad) destinationQuad andBlendMode:(WCMBlendMode) blendMode __attribute__ ((deprecated));


#pragma mark - Read Layer Pixels
/** @name  Read Layer Pixels */

/**
 @since 1.2
 @abstract Returns all the pixels of the layer set as a current target of the context.
 @return All the pixels of the layer set as a current target of the context.
 */
-(NSData*) readPixelsFromCurrentTarget;

/**
 @since 1.2
 @abstract Returns an UIImage containing all the pixels of the layer set as a current target of the context.
 @return An UIImage containing all the pixels of the layer set as a current target of the context.
 */
-(UIImage*) readPixelsAsUIImageFromCurrentTarget;

/**
 @since 1.2
 @abstract Returns an UIImage containing all the pixels of the layer set as a current target of the context.
 Unlike the readPixelsAsUIImageFromCurrentTarget, the result will be in UIImageOrientationUp. The method performs extra conversion work and is slightly slower than readPixelsAsUIImageFromCurrentTarget.
 @return An UIImage containing all the pixels of the layer set as a current target of the context.
 */
-(UIImage*) readPixelsAsUIImageFromCurrentTargetInUpOrientation;

/**
 @since 1.2
 @abstract Returns the pixels of the layer set as a current target of the context, from the rectangle specified by the rect parameter.
 @param rect The area from which the pixels are read.
 @return The pixels of the layer set as a current target of the context, from the rectangle specified by the rect parameter.
 */
-(NSData*) readPixelsFromCurrentTargetFromRect:(CGRect)rect;

/**
 @since 1.2
 @abstract Returns an UIImage containing the pixels of the layer set as a current target of the context, from the rectangle specified by the rect parameter.
 @param rect The area from which the pixels are read.
 @return An UIImage containing the pixels of the layer set as a current target of the context, from the rectangle specified by the rect parameter.
 */
-(UIImage*) readPixelsAsUIImageFromCurrentTargetFromRect:(CGRect)rect;

/**
 @since 1.2
 @abstract Returns an UIImage containing the pixels of the layer set as a current target of the context, from the rectangle specified by the rect parameter.
 Unlike the [WCMRenderingContext readPixelsAsUIImageFromCurrentTargetFromRect:], the result will be in UIImageOrientationUp. The method performs extra conversion work and is slightly slower than [WCMRenderingContext readPixelsAsUIImageFromCurrentTargetFromRect:].
 @param rect The area from which the pixels are read.
 @return An UIImage containing the pixels of the layer set as a current target of the context, from the rectangle specified by the rect parameter.
 */
-(UIImage*) readPixelsAsUIImageFromCurrentTargetFromRectInUpOrientation:(CGRect)rect;

#pragma mark - Write Layer Pixels
/** @name  Write Layer Pixels */

/**
 @since 1.2
 @abstract Sets all the pixels of the layer set as a current target of the context.
 @param pixels NSData containing the pixels.
 @discussion The length of the pixels must corresponds to the storageBounds of the layer.
 */
-(void) writePixelsInCurrentTarget:(NSData*)pixels;


/**
 @since 1.2
 @abstract Sets all the pixels of the layer set as a current target of the context.
 @param image UIImage containing the pixels.
 @discussion The size of the image must corresponds to the storageBounds of the layer.
 */
-(void) writePixelsInCurrentTargetFromUIImage:(UIImage *)image;

/**
 @since 1.2
 @abstract Sets the pixels of the area defined by the rect, of the layer set as a current target of the context.
 @param pixels NSData containing the pixels.
 @param rect CGRect defining the area
 @discussion The length of the pixels must corresponds to the rect scaled by the [WCMLayer scaleFactor] of the layer.
 */
-(void) writePixelsInCurrentTarget:(NSData*)pixels inRect:(CGRect)rect;

/**
 @since 1.2
 @abstract Sets the pixels of the area defined by the rect, of the layer set as a current target of the context.
 @param image UIImage containing the pixels.
 @param rect CGRect defining the area
 @discussion The size of the image must corresponds to the rect scaled by the [WCMLayer scaleFactor] of the layer.
 */
-(void) writePixelsInCurrentTargetFromUIImage:(UIImage *)image inRect:(CGRect)rect;

@end
