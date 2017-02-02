//
//  DrawView.h
//  inkluded-405
//
//  Created by Josh Choi on 1/22/17.
//  Copyright © 2017 Josh Choi. All rights reserved.
//

#ifndef DrawView_h
#define DrawView_h

#import <UIKit/UIKit.h>

@interface DrawView : UIView

- (void) saveStrokes;

- (void) decodeStrokesFromDocumentPath;

@end

#endif
