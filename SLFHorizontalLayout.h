//
//  SLFHorizontalLayout.h
//  Cyclorama
//
//  Created by iain on 29/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SLFBox.h"
#import "SLFBoxDelegate.h"

@interface SLFHorizontalLayout : NSView <SLFBoxDelegate>

typedef enum {
    SLFHorizontalLayoutNone = 0x0,
    SLFHorizontalLayoutFixedWidth = 0x1,
} SLFHorizontalLayoutOptions;

@property (readwrite) CGFloat containerSpacing;
@property (readwrite) CGFloat childSpacing;
@property (readwrite) BOOL debugDrawChildLayout;

- (void)addChild:(SLFBox *)childView
     withOptions:(SLFHorizontalLayoutOptions)options;

@end
