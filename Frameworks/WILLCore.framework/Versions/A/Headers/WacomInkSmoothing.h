//
//  WacomInkSmooting.h
//  WacomInk
//
//  Created by Plamen Petkov on 2/19/14.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WacomInkConfig.h"
#import "WacomInkUtil.h"

/**
 The WCMSmoothener class is used the smooth out the noise in a data sequence. The implementation is based on the double exponential smoothing technique. The result of the smooth operation will depend only on the last several values of the sequence. The WCMSmoothener class works best for touch input with rate of 60 events per second.
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMSmoothener : NSObject

/**
 @since 1.2
 @abstract Smooths the next value in the sequence.
 @param value The data value.
 @return The smoothed valued.
 */
-(float) smoothValue:(float)value;

/**
 @since 1.2
 @abstract Resets the smoother so it is ready for a new data sequence. For example if you are smoothing paths produced by the WCMAbstractPathBuilder class, you should call the [WCMSmoothener reset] method before each new path.
 */
-(void) reset;

@end

/**
 The WCMSmoothenerFinisher class will smoothly continue the data sequence to a desired value.
 
 Because the WCMSmoothener will naturally lag behind the actual data value, this class is designed to generate several values that will smoothly reach a desired value.
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMSmoothenerFinisher : NSObject

/**
 @since 1.2
 @abstract Initializes an instance of the WCMSmoothenerFinisher class with an existing WCMSmoothener and a target value that needs to be reached.
 @param smoother An initialized instance of the WCMSmoothener class. This instance will provide the smoothing state. The state of the WCMSmoothener will not be changed.
 @param value The target value that needs to be reached.
 @return  The initialized instance.
 */
-(id) initWithSmoother:(WCMSmoothener*)smoother andTargetValue:(float)value;

/**
 @since 1.2
 @abstract Return the next value of the sequence. This method is intended to be called until isDone returns NO.
 @return The next value of the finishing sequence.
 */
-(float) smooth;

/**
 @since 1.2
 @abstract Returns if the target value has been reached. The intended usage is to call the smooth method until this method returns NO.
 @return If the target value has been reached.
 */
-(BOOL) isDone;

@end

/**
 The WCMMultiChannelSmoothener is a utility class that groups together several instances of WCMSmoothener and WCMSmoothenerFinisher in order to make the smoothing of many independent data sequences more convenient. The most likely usage will be too smooth out the *x*, *y* and *width* fields of a path.
 By default all channels will be smoothed. This could be changed by calling the [WCMMultiChannelSmoothener setEnabled:forChannelWithIndex:] method.
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMMultiChannelSmoothener : NSObject

/**
 @since 1.2
 @abstract The count of the independent data sequences smoothed.
 */
@property (readonly) int channelsCount;

/**
 @since 1.2
 @abstract Initializes the WCMMultiChannelSmoothener. The channelsCount indicates how many independent data sequences we will smooth.
 @param channelsCount The count of the independent data sequences that will be smoothed.
 @return initialized instance of the WCMMultiChannelSmoothener class.
 */
-(id) initWithChannelsCount:(int)channelsCount;

/**
 @since 1.2
 @abstract Smooths the next values in the data sequences. The size of the values parameter must be a multiple of the channelsCount property.
 @param values Pointer to the data values. The size of the parameter must be a multiple of the channelsCount property.
 @param reachFinalValues If set to NO the size of the result will be equal to the size of the values parameter. If set to YES the size of the result could be greater to the size of the values parameter. The class will return a sequences that will smoothly reach the last set of the values passed. Meaning the last set of values will be equal to the last set of the values passed. It is important to note that in this case the internal state of the instance will not change.
 @return List with smoothed values.
 @discussion <b>The returned object is only valid while the instance is not modified and is alive. You should not store it. If you need to store the data, create a new WCMFloatVector initialized with the data of the result</b>
 */
-(WCMFloatVectorPointer*) smoothValues:(WCMFloatVectorPointer*)values reachFinalValues:(BOOL)reachFinalValues;

/**
 @since 1.2
 @abstract Sets whether or not to smooth the channel with the specified index.
 @param enabled If YES, the channel will be smoothed. If NO, the values for this channel will returned unchanged.
 @param channelIndex The index of the channel.
 */
- (void) setEnabled:(BOOL)enabled forChannelWithIndex:(int) channelIndex;

/**
 @since 1.2
 @abstract Resets the smoothers so it is ready for a new data sequence. For example if you are smoothing paths produced by the WCMAbstractPathBuilder class, you should call the [WCMMultiChannelSmoothener reset] method before each new path.
 */
-(void) reset;


@end
