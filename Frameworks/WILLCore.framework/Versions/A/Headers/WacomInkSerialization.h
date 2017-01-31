//
//  WacomInkSerialization.h
//  WacomInk
//
//  Created by Branimir Angelov on 5/19/14.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WacomInkConfig.h"
#import "WacomInkUtil.h"

/**
 * The WCMInkEncoder class implements incremental encoding approach for creating a binary
 * representation of multiple strokes. It utilises the ProtocolBuffer
 * Serialization library. Please refer to [Encoding/Decoding ink content](/general-concepts/serialization/) article for more details.
 * @see WCMInkDecoder
 * @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMInkEncoder : NSObject

/**
 @since 1.2
 @abstract Encodes a stroke. The typical usage is to create a new instance of the WCMInkEncoder class and then to call this method for every stroke you want to encode. After that you call the [WCMInkEncoder getBytes] method to obtain the binary representation of all the strokes.
 @param decimalScale The number of digits after the decimal point in a number that will be kept.
 @param points WCMFloatVector containing the control points of the stroke
 @param stride The stride of the control points of the stroke. It is the count (in floats) of the fields of each point.
 @param width The constant width of the stroke if it has one. If it has dynamic width, NAN should be passed.
 @param color The color of the stroke
 @param ts The starting value of the Catmull-Rom spline parameter (0 is the default value).
 @param tf The final value of the Catmull-Rom spline parameter (1 is the default value).
 */
-(void) encodePathWithPrecision:(unsigned int)decimalScale
                      andPoints:(WCMFloatVector*)points
                      andStride:(unsigned int)stride
                       andWidth:(float)width
                       andColor:(UIColor*)color
                          andTs:(float)ts
                          andTf:(float)tf;

/**
 @since 1.3
 @abstract Encodes a stroke. The typical usage is to create a new instance of the WCMInkEncoder class and then to call this method for every stroke you want to encode. After that you call the [WCMInkEncoder getBytes] method to obtain the binary representation of all the strokes.
 @param decimalScale The number of digits after the decimal point in a number that will be kept.
 @param points WCMFloatVector containing the control points of the stroke
 @param stride The stride of the control points of the stroke. It is the count (in floats) of the fields of each point.
 @param width The constant width of the stroke if it has one. If it has dynamic width, NAN should be passed.
 @param color The color of the stroke
 @param ts The starting value of the Catmull-Rom spline parameter (0 is the default value).
 @param tf The final value of the Catmull-Rom spline parameter (1 is the default value).
 @param blendMode The blendmode used when rendering the path.
 */
-(void) encodePathWithPrecision:(unsigned int)decimalScale
                      andPoints:(WCMFloatVector*)points
                      andStride:(unsigned int)stride
                       andWidth:(float)width
                       andColor:(UIColor*)color
                          andTs:(float)ts
                          andTf:(float)tf
                   andBlendMode:(WCMBlendMode) blendMode;

/**
 @since 1.3
 @abstract Encodes a stroke. The typical usage is to create a new instance of the WCMInkEncoder class and then to call this method for every stroke you want to encode. After that you call the [WCMInkEncoder getBytes] method to obtain the binary representation of all the strokes.
 @param decimalScale The number of digits after the decimal point in a number that will be kept.
 @param points WCMFloatVector containing the control points of the stroke
 @param stride The stride of the control points of the stroke. It is the count (in floats) of the fields of each point.
 @param width The constant width of the stroke if it has one. If it has dynamic width, NAN should be passed.
 @param color The color of the stroke
 @param ts The starting value of the Catmull-Rom spline parameter (0 is the default value).
 @param tf The final value of the Catmull-Rom spline parameter (1 is the default value).
 @param blendMode The blendmode used when rendering the path.
 @param paintIndex The index of the paint used when rendering.
 @param rngSeed The random number generator of the paint used when rendering.
 */
-(void) encodePathWithPrecision:(unsigned int)decimalScale
                      andPoints:(WCMFloatVector*)points
                      andStride:(unsigned int)stride
                       andWidth:(float)width
                       andColor:(UIColor*)color
                          andTs:(float)ts
                          andTf:(float)tf
                   andBlendMode:(WCMBlendMode) blendMode
                  andPaintIndex:(int) paintIndex
                andPaintRNGSeed:(uint32_t)rngSeed;

/**
 @since 1.2
 @abstract Returns the bytes representing the encoded strokes. It is produced by calling the [WCMInkEncoder encodePathWithPrecision:andPoints:andStride:andWidth:andColor:andTs:andTf:] method for every stroke you want to encode.
 @return The bytes representing the encoded strokes. It is produced by calling the [WCMInkEncoder encodePathWithPrecision:andPoints:andStride:andWidth:andColor:andTs:andTf:] method for every stroke you want to encode.
 */
-(NSData*) getBytes;

@end

/**
 The WCMVersion class represents a version used by the WCMWILLFileFormatEncoder and WCMWILLFileFormatDecoder classes. It follows the scheme: major.minor.patch.
 @since 1.3
 */
@interface WCMVersion : NSObject

/**
 Initializes a newly allocated WCMVersion with version numbers.
 @param major The major version number.
 @param minor The minor version number.
 @param patch The patch version number.
 @return an initialized instance of the WCMVersion class.
 */
- (instancetype) initWithMajor:(unsigned char)major andMinor:(unsigned char)minor andPatch:(unsigned char) patch;

/**
 @abstract The major version number.
 */
@property (readonly) unsigned char major;

/**
 @abstract The minor version number.
 */
@property (readonly) unsigned char minor;

/**
 @abstract The patch version number.
 */
@property (readonly) unsigned char patch;

@end


/**
 * The WCMInkDecoder class implements iterator-based interface for decoding compressed ink data, produced by the WCMInkEncoder.
 * Please refer to [Encoding/Decoding ink content](/general-concepts/serialization/) article for more details.
 * @see WCMInkEncoder
 * @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMInkDecoder : NSObject

/**
 @since 1.2
 @abstract Initializes the WCMInkDecoder instance with data.
 @param data NSData produced by the WCMInkEncoder.
 */
-(instancetype) initWithData:(NSData*)data;

/**
 @since 1.2
 @abstract Decodes a stroke data produced by the WCMInkEncoder.
 @param points Upon return will contain a WCMFloatVector containing the control points of the stroke.
 @param stride Upon return will contain the stride of the stroke.
 @param width Upon return will contain the width of the stroke.
 @param color Upon return will contain the color of the stroke.
 @param ts Upon return will contain the starting value for the Catmull-Rom spline parameter.
 @param tf Upon return will contain the final value for the Catmull-Rom spline parameter.
 @return Whether or not the decoding process was successful. It could be used as a indicator if we have reached the final stroke in the data.
 */
-(BOOL) decodePathToPoints:(WCMFloatVector**)points
                 andStride:(unsigned int*)stride
                  andWidth:(float*)width
                  andColor:(UIColor**)color
                     andTs:(float*)ts
                     andTf:(float*)tf;

/**
 @since 1.3
 @abstract Decodes a stroke data produced by the WCMInkEncoder.
 @param points Upon return will contain a WCMFloatVector containing the control points of the stroke.
 @param stride Upon return will contain the stride of the stroke.
 @param width Upon return will contain the width of the stroke.
 @param color Upon return will contain the color of the stroke.
 @param ts Upon return will contain the starting value for the Catmull-Rom spline parameter.
 @param tf Upon return will contain the final value for the Catmull-Rom spline parameter.
 @param blendMode Upon return will contain the blendmode used when rendering the path.
 @return Whether or not the decoding process was successful. It could be used as a indicator if we have reached the final stroke in the data.
 */
-(BOOL) decodePathToPoints:(WCMFloatVector**)points
                 andStride:(unsigned int*)stride
                  andWidth:(float*)width
                  andColor:(UIColor**)color
                     andTs:(float*)ts
                     andTf:(float*)tf
              andBlendMode:(WCMBlendMode*) blendMode;

/**
 @since 1.3
 @abstract Decodes a stroke data produced by the WCMInkEncoder.
 @param points Upon return will contain a WCMFloatVector containing the control points of the stroke.
 @param stride Upon return will contain the stride of the stroke.
 @param width Upon return will contain the width of the stroke.
 @param color Upon return will contain the color of the stroke.
 @param ts Upon return will contain the starting value for the Catmull-Rom spline parameter.
 @param tf Upon return will contain the final value for the Catmull-Rom spline parameter.
 @param blendMode Upon return will contain the blendmode used when rendering the path.
 @param paintIndex Upon return will contain the index of the paint used when rendering.
 @param rngSeed Upon return will contain the random number generator of the paint used when rendering.
 @return Whether or not the decoding process was successful. It could be used as a indicator if we have reached the final stroke in the data.
 */
-(BOOL) decodePathToPoints:(WCMFloatVector**)points
                 andStride:(unsigned int*)stride
                  andWidth:(float*)width
                  andColor:(UIColor**)color
                     andTs:(float*)ts
                     andTf:(float*)tf
              andBlendMode:(WCMBlendMode*) blendMode
             andPaintIndex:(int*) paintIndex
           andPaintRNGSeed:(uint32_t*)rngSeed;


/**
 @since 1.3
 @abstract Decodes a stroke data produced by the WCMInkEncoder.
 @param points Upon return will contain a WCMFloatVector containing the control points of the stroke.
 @param stride Upon return will contain the stride of the stroke.
 @param width Upon return will contain the width of the stroke.
 @param color Upon return will contain the color of the stroke.
 @param ts Upon return will contain the starting value for the Catmull-Rom spline parameter.
 @param tf Upon return will contain the final value for the Catmull-Rom spline parameter.
 @param blendMode Upon return will contain the blendmode used when rendering the path.
 @param paintIndex Upon return will contain the index of the paint used when rendering.
 @param rngSeed Upon return will contain the random number generator of the paint used when rendering.
 @param decimalScale The number of digits after the decimal point in a number that were present.
 @return Whether or not the decoding process was successful. It could be used as a indicator if we have reached the final stroke in the data.
 */
-(BOOL) decodePathToPoints:(WCMFloatVector**)points
                 andStride:(unsigned int*)stride
                  andWidth:(float*)width
                  andColor:(UIColor**)color
                     andTs:(float*)ts
                     andTf:(float*)tf
              andBlendMode:(WCMBlendMode*) blendMode
             andPaintIndex:(int*) paintIndex
           andPaintRNGSeed:(uint32_t*)rngSeed
           andDecimalScale:(unsigned int*)decimalScale;

@end


/**
 * <b>Deprecated in 1.5. Using the WCMWILLFileFormatEncoder is discouraged.</b>
 *
 * The WCMWILLFileFormatEncoder class takes data produced by the WCMInkEncoder and includes it into the WILL file format.
 * Please refer to [Exchanging ink content](/general-concepts/file-format/) article for more details.
 * @see WCMWILLFileFormatDecoder
 * @since 1.3
 */
WACOMINK_PUBLIC
__attribute__ ((deprecated))
@interface WCMWILLFileFormatEncoder : WCMRIFFEncoder

/**
 * @since 1.3
 * @abstract Adds encoded ink data produced by the WCMInkEncoder class instance.
 * @param payload The encoded ink data produced by the WCMInkEncoder class instance.
 */
-(void) addInkData:(NSData*)payload;

/**
 @since 1.3
 @abstract Returns the bytes representing the encoded will file format.
 @return The bytes representing the encoded will file format.
 */
-(NSData*) getBytes;

@end

/**
 * <b>Deprecated in 1.5. Using the WCMWILLFileFormatEncoder is discouraged.</b>
 *
 * The WCMWILLFileFormatDecoder class decodes the data produced by the WCMWILLFileFormatEncoder class. The result is a binary data that could be then decoded into individual strokes using the WCMInkDecoder class.
 * Please refer to [Exchanging ink content](/general-concepts/file-format/) article for more details.
 * @see WCMWILLFileFormatEncoder
 * @since 1.3
 */
WACOMINK_PUBLIC
__attribute__ ((deprecated))
@interface WCMWILLFileFormatDecoder : WCMRIFFDecoder

/**
 @since 1.3
 @abstract Initializes the WCMWILLFileFormatDecoder instance with data.
 @param data NSData produced by the WCMWILLFileFormatDecoderEncoder.
 */
-(instancetype) initWithData:(NSData*)data;

/**
 @abstract The decoded ink data. This data could be then decoded into individual strokes using the WCMInkDecoder class.
 */
@property (readonly) NSData* inkData;

/**
 @abstract The version numbers of the WILL format data.
 @since 1.3
 */
@property (readonly) WCMVersion* version;

@end


/**
 * The WCMPaintEncoder class implements incremental encoding approach for creating a binary
 * representation of multiple paints. It utilises the ProtocolBuffer Serialization library.
 * Please refer to [Encoding/Decoding ink content](/general-concepts/serialization/) article for more details.
 * @see WCMPaintDecoder
 * @since 1.3
 */
WACOMINK_PUBLIC
@interface WCMPaintEncoder : NSObject

/**
 @since 1.3
 @abstract Encodes a paint.
 @param paint The paint added to the encoded binary data.
 @return The index of the encoded paint.
 */
-(int) encodeParticlePaint:(WCMParticlePaint*)paint;

/**
 @since 1.3
 @abstract Returns the bytes representing the encoded paint.
 @return The bytes representing the encoded paint.
 */
-(NSData*) getBytes;

@end

/**
 * The WCMPaintDecoder class implements iterator-based interface for decoding compressed paint data, produced by the WCMPaintEncoder.
 * Please refer to [Encoding/Decoding ink content](/general-concepts/serialization/) article for more details.
 * @see WCMPaintEncoder
 * @since 1.3
 */
WACOMINK_PUBLIC
@interface WCMPaintDecoder : NSObject

/**
 @since 1.3
 @abstract Initializes the WCMPaintDecoder instance with data.
 @param data NSData produced by the WCMPaintEncoder.
 */
-(instancetype) initWithData:(NSData*)data;

/**
 @abstract Decodes a paint data produced by the WCMPaintEncoder.
 @param paint Upon return will contain a WCMParticlePaint containing the paint definition.
 @since 1.3
 */
-(BOOL) decodePaint:(WCMParticlePaint**)paint;

@end
