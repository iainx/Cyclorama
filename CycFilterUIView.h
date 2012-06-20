//
//  CycFilterUIView.h
//  FilterUIViewTest
//
//  Created by Iain Holmes on 01/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CycFilterUIView : NSView {
    NSMutableArray *xyParams;
    NSMutableArray *linearParams;
    double videoWidth;
    double videoHeight;
}

@property (readwrite, retain) CIFilter *filter;

- (id)initWithFilter:(CIFilter *)filter forScreenWidth:(double)_width screenHeight:(double)_height;

@end
