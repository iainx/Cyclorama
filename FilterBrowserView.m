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

- (void)setModel:(FilterModel *)model
{
    
    if (model == _model) {
        return;
    }
    
    _model = model;
    
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
    
    [self setFrameSize:NSMakeSize(frameWidth, frameHeight)];
    
    __block int yOffset = 5;
    
    [categories enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *categoryArray = (NSArray *) obj;
        int column = 0, i = 0;
        
        // FIXME: Draw label
        yOffset += 20;
        
        for (FilterItem *item in categoryArray) {
            FilterItemView *itemView = [[FilterItemView alloc] initWithFilterItem:item];
            int x;
            
            x = 5 + (column * 74.0) + ((column - 1) * 2);
            
            [itemView setFrameOrigin:NSMakePoint(x, yOffset)];
            
            [self addSubview:itemView];
            
            i++;
            column++;
            if (column > 2 && i < [categoryArray count]) {
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
