//
//  WacomInkUtil.h
//  WacomInk
//
//  Created by Plamen Petkov on 2/19/14.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "WacomInkConfig.h"

/**
 Blend modes enumeration.
 */
typedef NS_ENUM(NSUInteger, WCMBlendMode)
{
    /** Standard alpha composition. The source is on top of the destination. */
    WCMBlendModeNormal = 0,
    
    /** Like WCMBlendModeNormal, but the source is behind the destination. */
    WCMBlendModeReverse = 1,
    
    /** The opacity (alpha) of the source layer specify how much each component (red, gree, blue and alpha) of the destination to be reduced.*/
    WCMBlendModeErase = 2,
    
    /** No color mixing, the destination is overridden by the source. */
    WCMBlendModeNone=3,
    
    /** Alias for WCMBlendModeNone. */
    WCMBlendModeOverride = 3,
    
    /** For each component (red, gree, blue and alpha) the result is the larger value. The resulting color is lighter. */
    WCMBlendModeMax=4,
    
    /** For each component (red, gree, blue and alpha) the result is the smaller value. The resulting color is darker. */
    WCMBlendModeMin=5,
    
    /** For each component (red, gree, blue and alpha) the result is the sum of the source and the destination. */
    WCMBlendModeAdd=6,
    
    /** For each component (red, gree, blue and alpha) subtract the destination from the source. */
    WCMBlendModeSubstract=7,
    
    /** For each component (red, gree, blue and alpha) subtract the source from the destination. */
    WCMBlendModeSubstratReverse=8,
    
    /** For each component (red, gree, blue and alpha) source is multiplied by destination. */
    WCMBlendModeDirectMultiply=9,
    
    /** For each component (red, gree, blue and alpha) source is multiplied by destination and the product is subtracted from 1. */
    WCMBlendModeDirectMultiplyReverse=10,
    
    /** Deprecated naming. Use WCMBlendModeDirectMultiply instead.*/
    WCMBlendModeMultiplyNoAlphaComposition=9,
    
    /** Deprecated naming. Use WCMBlendModeDirectMultiplyReverse instead.*/
    WCMBlendModeMultiplyNoAlphaCompositionInvert=10
};

/**
 Specifies the rotation mode applied to each particle when rendering a stroke using a WCMParticleStrokeBrush instance.
 */
typedef NS_ENUM(NSUInteger, WCMStrokeBrushRotation)
{
    /** No rotation is applied. The sides of the particle's texture will be parallel to the coordinate system axis.*/
    WCMStrokeBrushRotationNone = 0,
    
    /** Each particle is a rotated a random amount around its center. */
    WCMStrokeBrushRotationRandom = 1,
    
    /** Each particle is rotates in such a way that it follows the trajectory of the stroke. The sides of the particle's texture will be parallel to the direction of stroke at that point. */
    WCMStrokeBrushRotationTrajectory = 2
};

typedef union
{
    struct
    {
        float x, y, width, alpha;
    };
    float asArray[4];
    
}  WCMStrokePoint;

static inline WCMStrokePoint WCMStrokePointMake(float x, float y, float width, float alpha)
{
    WCMStrokePoint result;
    result.x = x; result.y = y; result.width = width; result.alpha = alpha;
    return result;
}

static WCMStrokePoint kWCMStrokePointInf = {INFINITY, INFINITY, 0, 0};
static WCMStrokePoint kWCMStrokePointNull = {NAN, NAN, NAN, NAN};

/**
 Utility class that acts as a reference to a sequence of float values.
 The begin points to the first element and the end points just after the last element of the sequence. The typical usage of the class is to specify a region in a WCMFloatVector object. It is intended to be alive for a small period of time - until the method is done working the specified region in a WCMFloatVector.
 
 <b>This class is not an owner of the underlying data and it does not hold any references to it. If the data is modified or released, accessing it via this object will result in a memory error! In most cases you will use this object in a limited scope (a function call) and you will not store it. If need to store the data you could create a new instance of the WCMFloatVector initialized with the data pointed by the object.</b>
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMFloatVectorPointer : NSObject

/**
 @since 1.3
 @abstract Initializes and returns instance of WCMFloatVectorPointer. Data is NOT copied.
 @param begin Pointer to the to the first element of the list.
 @param end Pointer to the element after the last element of the list.
 @return Initialized instance of of WCMFloatVectorPointer.
 */
-(id) initWithBegin:(float*)begin andEnd:(float*)end;

/**
 @since 1.2
 @abstract Returns a *pointer* to the first element of the vector.
 @return A read-only *pointer* to the first element of the vector.
 */
-(float*) begin;

/**
 @since 1.2
 @abstract Returns a *pointer* after the last element of the vector.
 @return A read-only *pointer* after the last element of the vector.
 */
-(float*) end;


/**
 @since 1.2
 @abstract Returns the count of the elements in the vector.
 @return The count of the elements in the vector.
 */
-(size_t) size;

@end

/**
 Data collection class. Represents an immutable list of float values.
 The begin points to the first element and the end points just after the last element of the sequence.
 The implementation uses the C++ std::vector class.
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMFloatVector : NSObject

/**
 @since 1.2
 @abstract Creates and initializes a instance of WCMFloatVector class. The values will be copied.
 @param begin Pointer to the to the first element of the list.
 @param end Pointer to the element after the last element of the list.
 @return Initialized instance of of WCMFloatVector.
 */
+(WCMFloatVector*) vectorWithBegin:(float *)begin andEnd:(float*)end;

/**
 @since 1.2
 @abstract Returns a *pointer* to the first element of the vector.
 @return A read-only *pointer* to the first element of the vector.
 */
-(float*) begin;


/**
 @since 1.2
 @abstract Returns a *pointer* after the last element of the vector.
 @return A read-only *pointer* after the last element of the vector.
 */
-(float*) end;


/**
 @since 1.2
 @abstract Returns the count of the elements in the vector.
 @return The count of the elements in the vector.
 */
-(size_t)size;

/**
 @return a reference to the data without copying it.
 */
-(WCMFloatVectorPointer*)pointer;

/**
 @return a copy of the list's data.
 */
-(WCMFloatVector*) copy;

@end


/**
 Data collection class. Represents an immutable list of CGRect values.
 The begin points to the first element and the end points just after the last element of the sequence.
 The implementation uses the C++ std::vector class.
 @since 1.3
 */
WACOMINK_PUBLIC
@interface WCMCGRectVector : NSObject

/**
 @since 1.3
 @abstract Creates and initializes an instance of WCMCGRectVector class. The values will be copied.
 @param begin Pointer to the to the first element of the list.
 @param end Pointer to the element after the last element of the list.
 @return Initialized instance of of WCMCGRectVector.
 */
+(WCMCGRectVector*) vectorWithBegin:(CGRect *)begin andEnd:(CGRect*)end;

/**
 @since 1.3
 @abstract Creates and initializes an empty instance of WCMCGRectVector class with a size.
 @param size The size of the vector.
 */
+(WCMCGRectVector*) vectorWithSize:(size_t)size;

/**
 @since 1.3
 @abstract Returns a *pointer* to the first element of the vector.
 @return A read-only *pointer* to the first element of the vector.
 */
-(CGRect*) begin;


/**
 @since 1.3
 @abstract Returns a *pointer* after the last element of the vector.
 @return A read-only *pointer* after the last element of the vector.
 */
-(CGRect*) end;


/**
 @since 1.3
 @abstract Returns the count of the elements in the vector.
 @return The count of the elements in the vector.
 */
-(size_t)size;

/**
 @return a copy of the list's data.
 */
-(WCMCGRectVector*) copy;

@end


/**
 Data collection class. Represents an immutable list of integer values.
 The begin points to the first element and the end points just after the last element of the sequence.
 The implementation uses the C++ std::vector class.
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMIntVector : NSObject

/**
 @since 1.2
 @abstract Initializes and returns an instance of WCMIntVector class. The values will be copied.
 @param begin Pointer to the to the first element of the list.
 @param end Pointer to the element after the last element of the list.
 @return Initialized instance of of WCMIntVector.
 */
+(WCMIntVector*) vectorWithBegin:(int*)begin andEnd:(int*)end;

/**
 @since 1.2
 @abstract Returns a *pointer* to the first element of the vector.
 @return A read-only *pointer* to the first element of the vector.
 */
-(int*) begin;

/**
 @since 1.2
 @abstract Returns a *pointer* after the last element of the vector.
 @return A read-only *pointer* after the last element of the vector.
 */
-(int*) end;

/**
 @since 1.2
 @abstract Returns the count of the elements in the vector.
 @return The count of the elements in the vector.
 */
-(size_t)size;

/**
 @since 1.2
 @return a copy of the list's data.
 */
-(WCMIntVector*) copy;

@end

WACOMINK_PUBLIC
/**
 The WCMParticlePaint represents a definition of how a stroke is going to be rendered when using a particle scattering method. See WCMParticleStrokeBrush.
 @since 1.3
 */
@interface WCMParticlePaint : NSObject



/**
 @abstract Specifies several scale levels of the image used for tiling. After the stroke's shape (contour) is generated, it will be filled by tiling the image specified by this argument. The size of the tile is set by the fillTileSize argument. You provide an array of images with different resolutions. The dimensions of each images must be a power of 2. The images must be provided in decreasing order of their dimensions. The dimensions of each image in the array must be exactly half of the dimensions of the previous one.
 @since 1.3
 */
@property NSArray* fillTextureLevels; //of UIImage objects

/**
 @abstract The size of the tile used to fill the stroke. The tile will be filled with content of the images defined by the fillTextureLevels.
 @since 1.3
 */
@property CGSize fillTileSize;

/**
 @abstract Specifies several scale levels of the image used for each particle. You provide an array of images with different resolutions. The dimensions of each images must be a power of 2. The images must be provided in decreasing order of their dimensions. The dimensions of each image in the array must be exactly half of the dimensions of the previous one.
 @since 1.3
 */
@property NSArray* shapeTextureLevels; //of UIImage objects

/**
 @abstract Defines the separation between particles. The value must be greater than 0. Value of 1.0 means that the distance between two particles will be equal the average width of the two particles.
 @since 1.3
 */
@property CGFloat spacing;

/**
 @abstract Controls how much the particles will spread out sideways. Value of 0 means no spread out. Values of 1, means that each particle will be displaced sideways a random amount between 0% to 100% of its width.
 @since 1.3
 */
@property CGFloat scattering;

/**
 @abstract Specifies the blend mode with which each particle will be drawn.
 @since 1.3
 */
@property WCMBlendMode blendMode;

/**
 @abstract Specifies the rotation mode applied to each particle. See WCMStrokeBrushRotation.
 @since 1.3
 */
@property WCMStrokeBrushRotation rotationMode;

@end

/**
 Specifies a chunk of interchange file format (RIFF) data, identified by a 4-character tag.
 @since 1.3
 */
@interface WCMRIFFChunk : NSObject

/**
 @abstract The data of the chunk
 @since 1.3
 */
@property NSData* payload;

/**
 @abstract The chunk identifier. Must be a 4-character string. Only ASCII symbols allowed.
 @since 1.3
 */
@property NSString* fourCC;

@end

/**
 Decoder for the interchange file format (RIFF).
 @since 1.3
 */
@interface WCMRIFFDecoder : NSObject

/**
 @abstract Initializes an instance of WCMRIFFDecoder class with file data.
 @param data The RIFF data that is going to be decoded.
 @return an initialized instance of WCMRIFFDecoder class with file data.
 @since 1.3
 */
-(instancetype) initWithData:(NSData*)data;

/**
 @abstract Return the data of the chunk with the specified identifier.
 @param fourCC The chunk identifier. Must be a 4-character string. Only ASCII symbols allowed.
 @return the data of the chunk with the specified identifier.
 @since 1.3
 */
-(NSData*) getChunkPayloadWithFourCC:(NSString*)fourCC;

/**
 @abstract Return the data of the chunk with the specified index.
 @param index The index of the chunk (the first chunk is with index 0).
 @return the data of the chunk with the specified index.
 @since 1.3
 */
-(WCMRIFFChunk*) getChunkWithIndex:(int)index;

/**
 @abstract The identifier of the root list chunk. It is a 4-character string with only ASCII symbols.
 @since 1.3
 */
@property (readonly) NSString * rootFourCC;

@end

/**
 Encoder for the interchange file format (RIFF).
 @since 1.3
 */
@interface WCMRIFFEncoder : NSObject

/**
 @abstract Initializes an instance of WCMRIFFEncoder class with the identifier of the root list chunk. The identifier must be a 4-character string. Only ASCII symbols allowed.
 @param fourCC The identifier of the root list chunk. Must be a 4-character string. Only ASCII symbols allowed.
 @return an initialized instance of WCMRIFFEncoder class with the identifier of the root list chunk. The identifier must be a 4-character string. Only ASCII symbols allowed.
 @since 1.3
 */
-(instancetype) initWithFourCC:(NSString*)fourCC;

/**
 @abstract Adds a chunk data with the specified identifier.
 @param fourCC The chunk identifier. Must be a 4-character string. Only ASCII symbols allowed.
 @param payload The chunk data.
 @since 1.3
 */
-(void) addChunkWithFourCC:(NSString*)fourCC andPayload:(NSData*)payload;

/**
 @abstract Returns the encoded interchange file format (RIFF) bytes.
 @since 1.3
 */
-(NSData*) getBytes;

@end

#ifdef __cplusplus
extern "C" {
#endif
    
    /**
     Returns a CGRect that contains the 'rect' and has integer dimensions.
     @since 1.2
     */
    WACOMINK_PUBLIC
    static inline CGRect CGRectCeil(CGRect rect)
    {
        return CGRectMake(floor(rect.origin.x), floor(rect.origin.y), ceil(rect.size.width), ceil(rect.size.height));
    }
    
    /**
     This method calculates the bounds of a single segment of a path. A segment is the curve between two control points.
     @param points The control points of the path.
     @param pointsStride Defines the offset from one control point to the next.
     @param width The width of the path. If the control points include a width property value, this parameter should be NAN.
     @param index The index of the first control point of the segment for which we want to calculate the bounds. Each segment is defined by 4 consecutive control points. That is why the last segment has index equal to the count of the control points minus 3.
     @param scattering This parameter will increase the width of each point. A value of 1 will double the with. Value of 0 will have no offect and is the default value. Values greater than 0 are used for paths rendered with a particle brushes. See WCMStrokeBrush.
     @return The bounds of a single segment of a path with the index specified. A segment is the curve between two control points.
     @since 1.2
     */
    WACOMINK_PUBLIC
    CGRect WCMCalculateStrokeSegmentBounds(WCMFloatVectorPointer * points, int pointsStride, float width, int index, float scattering);
    
    /**
     This method calculates the bounds of a list of consecutive segment of a path. A segment is the curve between two control points.
     @param points The control points of the path.
     @param pointsStride Defines the offset from one control point to the next.
     @param width The width of the path. If the control points include a width property value, this parameter should be NAN.
     @param index The index of the first control point of the first segment of the list. Each segment is defined by 4 consecutive control points. That is why the last segment has index equal to the count of the control points minus 3.
     @param count The count of the segments of the list.
     @param scattering This parameter will increase the width of each point. A value of 1 will double the with. Value of 0 will have no offset and is the default value. Values greater than 0 are used for paths rendered with a particle brushes. See WCMStrokeBrush.
     @return The bounds of a list of consecutive segment of a path. A segment is the curve between two control points.
     @since 1.2
     */
    WACOMINK_PUBLIC
    CGRect WCMCalculateStrokeSegmentsBounds(WCMFloatVectorPointer * points, size_t pointsStride, float width, int index, size_t count, float scattering);
    
    /**
     This method calculates a vector of the bounds of the segments of a path. A segment is the curve between two control points.
     @param points The control points of the path.
     @param pointsStride Defines the offset from one control point to the next.
     @param width The width of the path. If the control points include a width property value, this parameter should be NAN.
     @param scattering This parameter will increase the width of each point. A value of 1 will double the with. Value of 0 will have no offset and is the default value. Values greater than 0 are used for paths rendered with a particle brushes. See WCMStrokeBrush.
     @return The a vector of the bounds of the segments of a path. A segment is the curve between two control points.
     @since 1.2
     */
    WACOMINK_PUBLIC
    WCMCGRectVector* WCMCalculateStrokeSegmentsBoundsVector(WCMFloatVectorPointer * points, size_t pointsStride, float width, float scattering);
    
    WACOMINK_PUBLIC
    void WCMTest();
    
#ifdef __cplusplus
}
#endif