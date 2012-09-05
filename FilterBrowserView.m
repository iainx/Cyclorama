//
//  FilterBrowserView.m
//  Cyclorama
//
//  Created by iain on 28/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Quartz/Quartz.h>
#import "FilterBrowserView.h"
#import "FilterItem.h"
#import "FilterItemView.h"
#import "FilterModel.h"

@implementation FilterBrowserView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithFilterModel:(FilterModel *)model
{
    self = [super initWithFrame:NSZeroRect];
    
    [self setModel:model];
    
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

#define BROWSER_GUTTER_SIZE 5
#define BROWSER_SPACING_SIZE 2
#define BROWSER_ITEMS_PER_ROW 3
- (void)setModel:(FilterModel *)model
{
    if (model == _model) {
        return;
    }
    
    _model = model;
    
    NSDictionary *categories = [model categories];
    float frameHeight;
    float frameWidth;
    __block NSInteger rowCount = 0;
    __block int yOffset = BROWSER_GUTTER_SIZE;

    frameWidth = (BROWSER_GUTTER_SIZE * 2) + (74.0 * BROWSER_ITEMS_PER_ROW) + (2 * BROWSER_SPACING_SIZE);

    // Layout the subviews and calculate the size of the view
    [categories enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *categoryArray = (NSArray *) obj;
        NSUInteger c = [categoryArray count];
        int column = 0, i = 0;
        
        rowCount += (c / BROWSER_ITEMS_PER_ROW);
        if (c % BROWSER_ITEMS_PER_ROW > 0) {
            rowCount++;
        }
        
        NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(10.0, yOffset, frameWidth - 20, 20.0)];
        [label setStringValue:[CIFilter localizedNameForCategory:key]];
        [label setBezeled:NO];
        [label setBordered:NO];
        [label setDrawsBackground:NO];
        [label setEditable:NO];
        [label setTextColor:[NSColor whiteColor]];
        
        [self addSubview:label];
        
        yOffset += 20;
        
        for (FilterItem *item in categoryArray) {
            FilterItemView *itemView = [[FilterItemView alloc] initWithFilterItem:item];
            int x;
            
            x = BROWSER_GUTTER_SIZE + (column * 74.0) + ((column - 1) * BROWSER_SPACING_SIZE);
            
            [itemView setFrameOrigin:NSMakePoint(x, yOffset)];
            
            [self addSubview:itemView];
            
            i++;
            column++;
            if (column >= BROWSER_ITEMS_PER_ROW && i < [categoryArray count]) {
                column = 0;
                yOffset += 53.0 + BROWSER_SPACING_SIZE;
            }
        }
        
        yOffset += 53.0;
    }];
    
    // yOffset still needs the bottom gutter added to it
    frameHeight = yOffset + BROWSER_GUTTER_SIZE;
    
    [self setFrameSize:NSMakeSize(frameWidth, frameHeight)];
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
