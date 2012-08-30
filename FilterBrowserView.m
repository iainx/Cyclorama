//
//  FilterBrowserView.m
//  Cyclorama
//
//  Created by iain on 28/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "FilterBrowserView.h"
#import "FilterItem.h"
#import "FilterItemView.h"
#import "FilterModel.h"

@implementation FilterBrowserView {
    CGFloat intrinsicWidth;
    CGFloat intrinsicHeight;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    NSLog(@"Init with frame %@", NSStringFromRect(frame));
    return self;
}

- (id)initWithFilterModel:(FilterModel *)model
{
    self = [super initWithFrame:NSZeroRect];
    
    [self setModel:model];
    
    return self;
}

- (void)awakeFromNib
{
    NSLog(@"Awake! %p", self);
}

- (BOOL)isFlipped
{
    return YES;
}
/*
- (NSSize)intrinsicContentSize
{
    return NSMakeSize(intrinsicWidth, intrinsicHeight);
}
*/
- (void)setModel:(FilterModel *)model
{
    
    if (model == _model) {
        NSLog(@"Model %p == _model %p", model, _model);
        return;
    }
    
    _model = model;
    
    NSLog(@"Hello?");
    NSDictionary *categories = [model categories];
    
    NSUInteger categoryCount = [categories count];
    __block NSInteger rowCount = 0;
    float frameHeight;
    float frameWidth;
    
    [categories enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *categoryArray = (NSArray *) obj;
        NSUInteger c = [categoryArray count];
        rowCount += (c / 3);
        
        if (c % 3 > 0) {
            rowCount++;
        }
    }];
    
    frameHeight = 10 + (20.0 * categoryCount) + (53.0 * rowCount) + (2 * (rowCount - 1));
    frameWidth = 10 + (74.0 * 3) + (2 * 2);
    
    //[self setFrame:NSMakeRect(0.0, 0.0, frameWidth, frameHeight)];
    intrinsicWidth = frameWidth;
    intrinsicHeight = frameHeight;
    [self setFrameSize:NSMakeSize(frameWidth, frameHeight)];
    
    NSLog(@"Size of %p frame is %@", self, NSStringFromRect([self bounds]));
    //[self invalidateIntrinsicContentSize];
    
    __block int yOffset = 5;
    
    [categories enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *categoryArray = (NSArray *) obj;
        int column = 0;
        
        // FIXME: Draw label
        yOffset += 20;
        
        for (FilterItem *item in categoryArray) {
            FilterItemView *itemView = [[FilterItemView alloc] initWithFilterItem:item];
            int x;
            
            x = 5 + (column * 74.0) + ((column - 1) * 2);
            
            [itemView setFrameOrigin:NSMakePoint(x, yOffset)];
            
            [self addSubview:itemView];
            
            column++;
            if (column > 2) {
                column = 0;
                yOffset += 53.0 + 2.0;
            }
        }
        
        yOffset += 53.0;
    }];
}

- (void)drawRect:(NSRect)dirtyRect
{
    /*
    CGContextRef cgContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSetRGBFillColor(cgContext, 1, 0, 0, 1);
    CGContextFillRect(cgContext, dirtyRect);
     */
}

@end
