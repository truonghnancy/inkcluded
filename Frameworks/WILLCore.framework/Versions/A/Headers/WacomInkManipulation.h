//
//  WacomInkManipulation.h
//  WacomInk
//
//  Created by Plamen Petkov on 2/25/14.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WacomInkConfig.h"
#import "WacomInkUtil.h"

/**
 WCMPathInterval structure defines interval of a path.
 @field fromIndex The index of the first point of the path interval.
 @field toIndex The index of the last point of the path interval.
 @field fromT The initial value of the Catmull-Rom parameter for the first curve of the path interval.
 @field toT The final value of the Catmull-Rom parameter for the last curve of the path interval.
 @field isInside A marker field. Used by the WCMIntersector class. It indicates whether or not a given interval belongs the intersection between a paths.
 */
typedef struct
{
    int fromIndex;
    int toIndex;
    
    float fromT;
    float toT;
    
    BOOL isInside;
    
} WCMPathInterval;

/**
 WCMIntersector is a class that calculates the intersection between a stroke and a target. A target could be another stroke, or the area enclosed by a path. On intersection the class will return a list of intervals. They will start from the beginning of the stroke and finish at the end of it. Every interval will be either entirely inside the target or entirely outside of it. In case when you use the [WCMIntersector setTargetAsClosedPathWithPoints: andPointsStride:] method, the target is the space enclosed by a path (that is why the width of the path is not relevant). With the [WCMIntersector setTargetAsStrokeWithPoints:andPointsStride:andWidth:] method, the target is the space inside the stroke (resulting from the width of the stroke). The class could be also used to make a fast check if the stroke and target are intersecting at all, without calculating intervals.
 @since 1.2
 */
WACOMINK_PUBLIC
@interface WCMIntersector : NSObject

/**
 @since 1.2
 @abstract Sets the target of intersection to be the space inside a stroke (resulting from the width of the stroke). Once set, the target could be intersect with many other strokes efficiently.
 @param points The control points of the stroke.
 @param pointsStride Defines the offset from one control point to the next.
 @param width The width of the stroke. If the control points has a value for the width, this parameter should be NAN.
 */
-(void) setTargetAsStrokeWithPoints:(WCMFloatVectorPointer *) points andPointsStride:(int) pointsStride andWidth:(float) width;

/**
 @since 1.2
 @abstract Sets the target of intersection to be the area enclosed by a path (that is why the width of the path is not relevant). Once set, the target could be intersect with many strokes efficiently.
 @param points The control points of the path.
 @param pointsStride Defines the offset from one control point to the next.
 */
-(void) setTargetAsClosedPathWithPoints:(WCMFloatVectorPointer *) points andPointsStride:(int) pointsStride;

/**
 @since 1.2
 @abstract Checks if the target set intersects the stroke passed.
 @param points The control points of the stroke.
 @param pointsStride The offset from one control point to the next.
 @param width The width of the stroke. If the stroke has variable width, which is included in the points array, this parameter must be NAN.
 @param ts The starting value of the Catmull-Rom spline parameter.
 @param tf The final value of the Catmull-Rom spline parameter.
 @param strokeBounds The bounds of the stroke.
 @param segmentsBounds Array containing the bounds of the stroke's segments. A segment with index <b><i>i</i></b> is the curve defined by the control points from index <b><i>i</i></b> to <b><i>i+3</i></b>.
 @return Whether or not the stroke is intersecting the target.
 */
-(BOOL) isIntersectingTarget:(WCMFloatVectorPointer *) points  andPointStride:(int) pointsStride andWidth:(float) width andTs:(float) ts andTf:(float) tf andStrokeBounds:(CGRect)strokeBounds andSegmentsBounds:(CGRect[])segmentsBounds;

/**
 @since 1.2
 @abstract Calculates intersection intervals of the stroke passed with the target set. Returns a pointer to the first element of a list of intervals. The intervals will cover the whole stroke. They will start from the beginning of the stroke and finish at the end of it. Every interval will be either entirely inside the target or entirely outside of it. In case when you use the [WCMIntersector setTargetAsClosedPathWithPoints: andPointsStride:] method, the target is the space enclosed by a path (that is why the width of the path is not relevant). With the [WCMIntersector setTargetAsStrokeWithPoints:andPointsStride:andWidth:] method, the target is the space inside the stroke (resulting from the width of the stroke). The intervals count will be returned in the out parameter: *intervalsCount*.
 @param points The control points of the stroke.
 @param pointsStride The offset from one control point to the next.
 @param width The width of the stroke. If the stroke has variable width, which is included in the points array, this parameter must be NAN.
 @param ts The starting value of the Catmull-Rom spline parameter.
 @param tf The final value of the Catmull-Rom spline parameter.
 @param strokeBounds The bounds of the stroke.
 @param segmentsBounds Array containing the bounds of the stroke's segments. A segment with index <b><i>i</i></b> is the curve defined by the control points from index <b><i>i</i></b> to <b><i>i+3</i></b>.
 @param intervalsCount Out parameter that upon return will contain the count of the calculated intervals.
 @return Pointer to the first element of a array of *WCMPathInterval* structures. The intervals will cover the whole stroke. They will start from the beginning of the stroke and finish at the end of it. Every interval will be either entirely inside the target or entirely outside of it. This information will be stored in the *isInside* field of the *WCMPathInterval* struct. The intervals count will be returned in the out parameter: *intervalsCount*.
 */
-(WCMPathInterval*) intersectTargetWith:(WCMFloatVectorPointer *) points  andPointStride:(int) pointsStride andWidth:(float) width andTs:(float) ts andTf:(float) tf andStrokeBounds:(CGRect)strokeBounds andSegmentsBounds:(CGRect[])segmentsBounds intervalsCount:(out size_t*)intervalsCount;

@end