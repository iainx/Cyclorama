//
//  CALayer+Images.m
//  Cyclorama
//
//  Created by iain on 05/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "CALayer+Images.h"

@implementation CALayer (Images)

- (NSImage *)createImageForLayer
{
    CGContextRef cgContext;
    CGColorSpaceRef colorspace;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    int height = [self bounds].size.height;
    int width = [self bounds].size.width;
    
    bitmapBytesPerRow = width * 4;
    bitmapByteCount = height * bitmapBytesPerRow;
    
    colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    cgContext = CGBitmapContextCreate(NULL, width, height, 8, bitmapBytesPerRow, colorspace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorspace);
    
    if (cgContext == NULL) {
        NSLog(@"Failed to create context");
        return nil;
    }
    
    [[self presentationLayer] renderInContext:cgContext];
    CGImageRef layerImage = CGBitmapContextCreateImage(cgContext);
    
    NSImage *img = [[NSImage alloc] initWithCGImage:layerImage
                                               size:NSZeroSize];
    CFRelease(layerImage);
    CGContextRelease(cgContext);
    
    return img;
}

@end
