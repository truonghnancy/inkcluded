//
//  Stroke.h
//  inkluded-405
//
//  Created by Josh Choi on 1/23/17.
//  Copyright © 2017 Josh Choi. All rights reserved.
//

#ifndef Stroke_h
#define Stroke_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WILLCore/WacomInkUtil.h"

@interface Stroke : NSObject

+(Stroke*) strokeWithPoints:(WCMFloatVector*)points andStride:(int)stride andWidth:(float)width andColor:(UIColor*)color andTs:(float)ts andTf:(float)tf andBlendMode:(WCMBlendMode)blendmode;

@property float width;
@property UIColor* color;
@property int stride;
@property float ts, tf;
@property WCMBlendMode blendMode;

@property (readonly) WCMFloatVector* points;

@end

#endif /* Stroke_h */
