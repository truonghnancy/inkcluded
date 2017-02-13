//
//  WacomInkInkPath.h
//  WacomInk
//
//  Created by Plamen Petkov on 2/18/14.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WacomInkConfig.h"
#import "WacomInkUtil.h"

/**
 Enumeration of the property functions supported by the WCMAbstractPathBuilder subclasses.
 */
typedef NS_ENUM(NSUInteger, WCMPropertyFunction)
{
    /**
     The function f(x) = x^a. When a is 1.0, the function becomes f(x) = x, the identity.
     */
    WCMPropertyFunctionPower = 1,
    
    /**
     Periodic function that cycles between the minimum and maximum value. The parameter sets the number of half-cycles.
     When the parameter is odd number, the function will begin with the minimum value and will finish with the maximum value.
     When period is even number the function starts and finish with the same value.
     */
    WCMPropertyFunctionPeriodic = 2,
    
    /**
     A sigmoid function is a function having an "S" shape. It goes from the minimum to the maximum value.
     It accelerates from the start to the middle and then decelerates to the end. The parameter controls the acceleration.
     */
    WCMPropertyFunctionSigmoid = 3
};

/**
 Enumeration of the properties of a path, constructed by the WCMAbstractPathBuilder subclasses.
 */
typedef NS_ENUM(NSUInteger, WCMPropertyName)
{
    /**
     The width property of a path build by the WCMAbstractPathBuilder subclasses.
     */
    WCMPropertyNameWidth = 1,
    
    /**
     The alpha (of the color) property of a path build by the WCMAbstractPathBuilder subclasses.
     */
    WCMPropertyNameAlpha = 2
};

/**
 Enumeration of the input phases used by the subclasses of the WCMAbstractPathBuilder class.
 */
typedef NS_ENUM(NSUInteger, WCMInputPhase)
{
    /**
     The begin phase of the input. The input has began.
     */
    WCMInputPhaseBegin = 1,
    
    
    /**
     The move phase of the input. The input has changed its position.
     */
    WCMInputPhaseMove = 2,
    
    /**
     The end phase of the input. The input has been completed.
     */
    WCMInputPhaseEnd = 3
};

/**
 This class is returned by a path append operation: [WCMAbstractPathBuilder addPathPart:].
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMPathAppendResult : NSObject

/**
 @since 1.2
 @abstract Returns all the points of the path.
 @return All the points of the path.
 @discussion <b>This property is only valid while the WCMAbstractPathBuilder instance is not modified and is alive. You should not store it. If you need to store the data, create a new WCMFloatVector initialized with the data of the result</b>
 */
@property (readonly) WCMFloatVectorPointer* wholePath;

/**
 @since 1.2
 @abstract Returns the count (in floats) of the points added by the [WCMAbstractPathBuilder addPathPart:] call.
 @return the count (in floats) of the points added by the append operation.
 */
@property (readonly) size_t addedSize;

/**
 @since 1.2
 @abstract Returns the first index of the path part added by the [WCMAbstractPathBuilder addPathPart:] call.
 @return the first index of the path part added by the [WCMAbstractPathBuilder addPathPart:] call.
 */
@property (readonly) size_t addedPartStartingIndex;

/**
 @since 1.2
 @abstract Returns a WCMFloatVectorPointer containing the points added by the [WCMAbstractPathBuilder addPathPart:] call.
 @return a WCMFloatVectorPointer containing the points added by the [WCMAbstractPathBuilder addPathPart:] call.
 @discussion <b>This property is only valid while the WCMAbstractPathBuilder instance is not modified and is alive. You should not store it. If you need to store the data, create a new WCMFloatVector initialized with the data of the result</b>
 */
@property (readonly) WCMFloatVectorPointer* addedPath;

@end

/**
 WCMAbstractPathBuilder and its two concrete subclasses: WCMSpeedPathBuilder and WCMPressurePathBuilder, are used to translate user input into geometry representation of a stroke. Roughly said it converts a series of (x,y) or (x,y,pressure) data into series of (x, y, width, alpha) control points of a spline. Those control points than could be rendered as stroke, or used in other ways. Each point is represented by the following numbers (of type float) in this order: "x", "y" , "width" and "alpha". The "x" and "y" values are always present. The "width" and "alpha" are included only when they are configured by the [WCMAbstractPathBuilder setPropertyConfigWithName:andMinValue:andMaxValue:andInitialValue:andFinalValue:andFunction:andParameter:andFlip:] method. The [WCMAbstractPathBuilder calculateStride] method returns the number of properties representing each point (it is 2 when only "x" and "y" are present, 3 when we have "x", "y" and "width" or "x", "y" and "alpha" and 4 when we have  "x", "y" , "width" and "alpha").
 
 The typical usage of the class is the following:
 
 - You configure the [WCMAbstractPathBuilder setNormalizationConfigWithMinValue:andMaxValue:].
 
 - You configure the [WCMAbstractPathBuilder setPropertyConfigWithName:andMinValue:andMaxValue:andInitialValue:andFinalValue:andFunction:andParameter:andFlip:] for the "width" and/or "alpha" if we want them to vary depending on the user input.
 
 - You call [WCMAbstractPathBuilder addPointWithPhase:andX:andY:andTimestamp:orPressure:] for every UITouch event.
 
 - Optionally you smooth out the result of the previous step, using the WCMMultiChannelSmoothener class.
 
 - You pass the result of the previous step to the [WCMAbstractPathBuilder addPathPart:] method.
 
 - You draw the returned result using [WCMPathAppendResult addedPath].
 
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMAbstractPathBuilder : NSObject

/**
 @since 1.2
 @abstract Sets the movement threshold - the minimal distance threshold between two input events. The default value is 0, meaning that there is no restriction on the distance (<b>but input evnt with exactly the same values for x and y as the previous one, will still be ignored!</b>). For values greater than 0, the path builder will ignore new points, until the distance from the new point to the previously added point is greater than the parameter
 @param minMovement The minimum movement.
 */
-(void) setMovementThreshold:(float) minMovement;

/**
 @since 1.2
 @abstract Calculates the stride of the points produced by the PathBuilder. The stride is the offset from one control point to the next. The control points are returned by the [WCMAbstractPathBuilder addPathPart:] method.
 @return The stride of the points produced by the PathBuilder.
 @discussion A path builder could be configured to produce points that have "x","y", "width" and "alpha" fields. The default value of the side is 2 (meaning the control points have “x” and “y” properties). If you call the [WCMAbstractPathBuilder setPropertyConfigWithName:andMinValue:andMaxValue:andInitialValue:andFinalValue:andFunction:andParameter:andFlip:] method for the “width” or “alpha”, the stride will become 3. If you configure both of them the stride will be 4.
 */
-(int) calculateStride;

/**
 @since 1.2
 @abstract Returns the control point of the path at the index specified. The WCMStrokePoint structure has all the fields that the path could have(x,y,width and alpha). If the path is missing fields (for example has only x and y), the missing fields will be set to NAN.
 @param index The index of the point returned.
 @return The point of the path at index.
 */
-(WCMStrokePoint) pointAtIndex:(int)index;

/**
 @since 1.2
 @abstract Returns the count of the control points.
 @return The count of all points.
 */
-(size_t) pointsCount;

/**
 @since 1.2
 @abstract Sets the min and max values that will be used for clamping the input values. Input values could be pressure or speed, depending of the concrete class used (WCMSpeedPathBuilder or WCMPressurePathBuilder). For WCMSpeedPathBuilder, this method specifies the minimum and maximum speed (measured in points per second) in interest. For the WCMPressurePathBuilder this method should set the range of valid pressure values.
 @param minValue The minimum value.
 @param maxValue The maximum value.
 */
-(void) setNormalizationConfigWithMinValue:(float) minValue andMaxValue:(float) maxValue;

/**
 @since 1.2
 @abstract Sets a property configuration. A property configuration guides the values that will be produced. A property could be the  width, or the alpha of the path for each control point.
 
 @param name The name  of the property that will be configured. See WCMPropertyName.
 @param minValue The minimum value of the property.
 @param maxValue The maximum value of the property.
 @param initialValue The initial value of the property at the begging of the path. Could be set to NAN. In this case the value will be same as the next point.
 @param finalValue The final value of the property at the end of the stroke. Could be set to NAN. In this case the value will be same as the previous point.
 @param function The function that will convert the input into a property value. See WCMPropertyFunction.
 @param functionParameter The parameter if the function. Parameter of the WCMPropertyFunction specified by the function parameter.
 @param flip If set to NO, the property will increase as the input increase. Otherwise the property will increase as the input decreases.
 */
-(void) setPropertyConfigWithName:(WCMPropertyName) name andMinValue:(float)minValue andMaxValue:(float)maxValue
                  andInitialValue:(float) initialValue andFinalValue:(float)finalValue andFunction:(WCMPropertyFunction)function
                     andParameter:(float) functionParameter andFlip:(bool) flip;

/**
 @since 1.2
 @abstract Adds a new part to the path. The typical case is first to call the [WCMAbstractPathBuilder addPointWithPhase:andX:andY:andTimestamp:orPressure:] method and then pass the result of it to the [WCMAbstractPathBuilder addPathPart:] method. Optionally you could smooth the result using WCMMultiChannelSmoothener class before calling this method.
 @param points Instance of the WCMFloatVectorPointer class containing the control points of the path.
 @return Instance of type WCMPathAppendResult.
 @discussion <b>The returned object is only valid while the instance is not modified and is alive. You should not store it. If you need to store the data, create a new WCMFloatVector initialized with the data of the result</b>
 @discussion <b>This property is only valid while the WCMAbstractPathBuilder instance is not modified and is alive. You should not store it. If you need to store the data, create a new WCMFloatVector initialized with the data of the result</b>
 */
-(WCMPathAppendResult*) addPathPart:(WCMFloatVectorPointer*)points;


/**
 @since 1.2
 @abstract The method calculates a path part (a set of control points) without updating the path builder state. This path part will behave like the path is being finished. The returned path part can be modified by clients (for example, it can be smoothed). After that the part should be passed to the [WCMAbstractPathBuilder finishPreliminaryPath:] method.
 @discussion <b>The returned object is only valid while the instance is not modified and is alive. You should not store it. If you need to store the data, create a new WCMFloatVector initialized with the data of the result</b>
 */
-(WCMFloatVectorPointer*) createPreliminaryPath;

/**
 @since 1.2
 @abstract  Gets the preliminary path for the path ending.
 @param points Instance of the WCMFloatVectorPointer class containing the control points of the path.
 @return array of points.
 @discussion <b>The returned object is only valid while the instance is not modified and is alive. You should not store it. If you need to store the data, create a new WCMFloatVector initialized with the data of the result</b>
 */
-(WCMFloatVectorPointer*) finishPreliminaryPath:(WCMFloatVectorPointer*)points;

/**
 @since 1.2
 @abstract This method will call [WCMPressurePathBuilder addPointWithPhase:andX:andY:andPressue:] or [WCMSpeedPathBuilder addPointWithPhase:andX:andY:andTimestamp:] depending of concrete class.
 
 The method calculates a path part (a set of control points) from the provided input. The returned path part can be modified by clients (for example it can be smoothed). After that the part should be added it to the currently built path with the [WCMAbstractPathBuilder addPathPart:] method.
 @param phase The phase of the input.
 @param x The x of the input.
 @param y The y of the input.
 @param timestamp The timestamp of the input (in seconds).
 @param pressure The value of the pressure sensor.
 @return Array of the points added.
 @discussion <b>The returned object is only valid while the instance is not modified and is alive. You should not store it. If you need to store the data, create a new WCMFloatVector initialized with the data of the result</b>
 */
-(WCMFloatVectorPointer*) addPointWithPhase:(WCMInputPhase) phase andX:(float) x andY:(float)y andTimestamp:(double) timestamp orPressure:(float)pressure;

@end

/**
 Path builder using pressure values for calculating the stroke dynamics (width and/or alpha).
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMPressurePathBuilder : WCMAbstractPathBuilder

/**
 @since 1.2
 @abstract The method calculates a path part (a set of control points) from the provided input. The returned path part can be modified by clients (for example it can be smoothed). After that the part should be added it to the currently built path with the [WCMAbstractPathBuilder addPathPart:] method.
 @param phase The phase of the input.
 @param x The x of the input.
 @param y The y of the input.
 @param pressure The value of the pressure sensor.
 @return Array of the points added.
 @discussion <b>The returned object is only valid while the instance is not modified and is alive. You should not store it. If you need to store the data, create a new WCMFloatVector initialized with the data of the result</b>
 */
-(WCMFloatVectorPointer*) addPointWithPhase:(WCMInputPhase) phase andX:(float) x andY:(float)y andPressue:(float) pressure;

@end

/**
 Path builder using input speed values for calculating stroke dynamics (width and/or alpha). The speed is the distance measured in points traveled by the UITouch for 1 second. The speed at each point will determine the width or/and alpha of the path at that point.
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMSpeedPathBuilder : WCMAbstractPathBuilder

/**
 @since 1.2
 @abstract The method calculates a path part (a set of control points) from the provided input. The returned path part can be modified by clients (for example it can be smoothed). After that the part should be added it to the currently built path with the [WCMAbstractPathBuilder addPathPart:] method.
 @param phase The phase of the input.
 @param x The x of the input.
 @param y The y of the input.
 @param timestamp The timestamp of the input (in seconds).
 @return Array of the points added.
 @discussion <b>The returned object is only valid while the instance is not modified and is alive. You should not store it. If you need to store the data, create a new WCMFloatVector initialized with the data of the result</b>
 */
-(WCMFloatVectorPointer*) addPointWithPhase:(WCMInputPhase) phase andX:(float) x andY:(float)y andTimestamp:(double) timestamp;

@end

/**
 This class is used to generate an UIBezierPath from WILL paths generated by the WCMAbstractPathBuilder subclasses.
 
 The typical usage of the class is the following:
 
 - Create an instance of the WCMBezierPathUtils.
 
 - Call the [WCMBezierPathUtils addPathPoints:andStride:andWidth:] for each WILL path, that needs to be included in a single UIBezierPath object.
 
 - Finally, call the [WCMBezierPathUtils createUIBezierPath] method, which will return the UIBezierPath instance.
 
 NOTE: Very small differences between the original path rendered with WILL and the produced UIBezierPath are expected, mainly in the anti-aliasing.
 
 @since 1.4
 */
WACOMINK_PUBLIC
@interface WCMBezierPathUtils : NSObject

/**
 @abstract Adds a path created by a WCMAbstractPathBuilder concrete subclass.
 @param points The points of the path generated using a WCMAbstractPathBuilder concrete subclass instance.
 @param stride The stride of the path generated using a WCMAbstractPathBuilder subclass instance. (Obtained by the [WCMAbstractPathBuilder calculateStride] method).
 @param width The width of the path generated using a WCMAbstractPathBuilder subclass instance. If set, the path has a constant width. If set to NaN the path has variable width, and the stride should be at least 3 (meaning that each point will cary a width value).
 @since 1.4
 */

-(void) addPathPoints:(WCMFloatVectorPointer*)points andStride:(int)stride andWidth:(float)width;

/**
 @abstract Adds a path created by a WCMAbstractPathBuilder concrete subclass.
 @param points The points of the path generated using a WCMAbstractPathBuilder concrete subclass instance.
 @param stride The stride of the path generated using a WCMAbstractPathBuilder subclass instance. (Obtained by the [WCMAbstractPathBuilder calculateStride] method).
 @param width The width of the path generated using a WCMAbstractPathBuilder subclass instance. If set, the path has a constant width. If set to NaN the path has variable width, and the stride should be at least 3 (meaning that each point will cary a width value).
 @param ts The starting value for the Catmull-Rom spline parameter of the first curve of spline (0 is the default value).
 @param tf The final value for the Catmull-Rom spline parameter of the last curve of the spline (1 is the default value).
 
 @since 1.4
 */

-(void) addPathPoints:(WCMFloatVectorPointer*)points andStride:(int)stride andWidth:(float)width andTs:(float)ts andTf:(float)tf;

/**
 @abstract Returns an instance of the UIBezierPath class that represents the boundaries of paths added by the [WCMBezierPathUtils addPathPoints:andStride:andWidth:] method. <b> Repetitive calls of this method will return nil, until you add new paths with the [WCMBezierPathUtils addPathPoints: andStride: andWidth:] method. </b>
 @return instance of the UIBezierPath class that represents the boundaries of paths added by the [WCMBezierPathUtils addPathPoints:andStride:andWidth:] method calls.
 @since 1.4.
 */
-(UIBezierPath*) createUIBezierPath;

/**
 @abstract TODO: document
 @since 1.5.
 */
-(UIBezierPath*) createFlattenedPath;

/**
 @abstract A step in the process of generating a Bezier curve, is to flatten the original path. This parameter specifies the maximum error between the path and its flattened approximation. Reducing the flatness increases the number of lines generated and thus decreases the performance. The default value is 0.1. <b>This parameter must be greater than 0. Setting it to 0 will produce unexpected results or crash. </b>
 @since 1.4.
 */
@property float flatteningTolerance;

/**
 @abstract This parameter specifies the maximum error between the flatten approximation of the original path and the generated Bezier curve. Reducing it, could increases the number of the generated curves. The default value is 0.2.
 @since 1.4.
 */
@property float curveFittingTolerance;

@end