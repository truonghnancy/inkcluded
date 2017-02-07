//
//  Stroke.m
//  inkluded-405
//
//  Created by Josh Choi on 1/23/17.
//  Copyright © 2017 Josh Choi. All rights reserved.
//

#import "Stroke.h"

@implementation Stroke

// Used to represent a stroke for storage/serialization.
+(Stroke*) strokeWithPoints:(WCMFloatVector*)points andStride:(int)stride andWidth:(float)width andColor:(UIColor*)color andTs:(float)ts andTf:(float)tf andBlendMode:(WCMBlendMode)blendmode
{
    Stroke * result = [[Stroke alloc] init];
    result->_points = points;
    result->_stride = stride;
    result->_width = width;
    result->_color = color;
    result->_ts = ts;
    result->_tf = tf;
    result->_blendMode = blendmode;
    
    return result;
}

@end
