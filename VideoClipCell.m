//
//  VideoClipCell.m
//  Cyclorama
//
//  Created by Iain Holmes on 13/09/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import "VideoClipCell.h"

@implementation VideoClipCell

@synthesize subtitle;
@synthesize thumbnail;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    VideoClipCell *cell = [super copyWithZone:zone];
    if (cell == nil) {
        return nil;
    }
    
    cell->thumbnail = nil;
    cell->subtitle = nil;
    [cell setThumbnail:[self thumbnail]];
    [cell setSubtitle:[self subtitle]];
    
    return cell;
}


- (NSAttributedString *)attributedSubtitleValue
{
    NSAttributedString *astr = nil;
    
    if (subtitle) {
        NSColor *textColour = [self isHighlighted] ? [NSColor lightGrayColor] : [NSColor grayColor];
        NSDictionary *attrs = @{NSForegroundColorAttributeName: textColour};
        astr = [[NSAttributedString alloc] initWithString:subtitle attributes:attrs];
    }
    
    return astr;
}

#pragma mark - Bound calculations

- (NSRect)imageRectForBounds:(NSRect)bounds
{
    NSRect imageRect = bounds;
    
    imageRect.origin.x += 5;
    imageRect.origin.y += 5;
    imageRect.size.width = 64;
    imageRect.size.height = 64;
    
    return imageRect;
}

- (NSRect)titleRectForBounds:(NSRect)bounds
{
    NSRect titleRect = bounds;
    
    titleRect.origin.x += 74;
    titleRect.origin.y += 5;
    
    NSAttributedString *title = [self attributedStringValue];
    if (title) {
        titleRect.size = [title size];
    } else {
        titleRect.size = NSZeroSize;
    }
    
    CGFloat maxX = NSMaxX(bounds);
    CGFloat maxWidth = maxX - NSMinX(titleRect);
    if (maxWidth < 0) {
        maxWidth = 0;
    }
    
    titleRect.size.width = MIN(NSWidth(titleRect), maxWidth);
    
    return titleRect;
}

- (NSRect)subtitleRectForBounds:(NSRect)bounds forTitleBounds:(NSRect)titleBounds
{
    NSRect subtitleRect = bounds;
    
    if (!subtitle) {
        return NSZeroRect;
    }
    
    subtitleRect.origin.x += 74;
    subtitleRect.origin.y = NSMaxY(titleBounds) + 5;
    
    CGFloat amountPast = NSMaxX(subtitleRect) - NSMaxX(bounds);
    if (amountPast > 0) {
        subtitleRect.size.width -= amountPast;
    }
    
    return subtitleRect;
}

- (NSSize)cellSizeForBounds:(NSRect)bounds
{
    NSSize size;
    
    size.width = 74 + [self titleRectForBounds:bounds].size.width;
    size.height = 74;
    
    size.width = MIN(size.width, NSWidth(bounds));
    size.height = MIN(size.height, NSHeight(bounds));
    
    return size;
}

#pragma mark - Drawing

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect imageRect = [self imageRectForBounds:cellFrame];
    if (thumbnail) {
        [thumbnail drawInRect:imageRect
                     fromRect:NSZeroRect
                    operation:NSCompositeSourceIn
                     fraction:1.0];
    } else {
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:imageRect];
        [[NSColor grayColor] set];
        [path fill];
    }
    
    NSRect titleRect = [self titleRectForBounds:cellFrame];
    NSAttributedString *aTitle = [self attributedStringValue];
    if ([aTitle length] > 0) {
        [aTitle drawInRect:titleRect];
    }
    
    NSRect subtitleRect = [self subtitleRectForBounds:cellFrame forTitleBounds:titleRect];
    NSAttributedString *aSubtitle = [self attributedSubtitleValue];
    if ([aSubtitle length] > 0) {
        [aSubtitle drawInRect:subtitleRect];
    }
}

@end
