//
//  SLFLabel.m
//  Cyclorama
//
//  Created by iain on 29/10/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "SLFLabel.h"

@implementation SLFLabel {
    NSTextStorage *_textStorage;
    NSLayoutManager *_layoutManager;
    NSTextContainer *_textContainer;
}

#define SNRButtonBlackTextShadowOffset            NSMakeSize(0.f, 1.f)
#define SNRButtonBlackTextShadowBlurRadius        -1.f
#define SNRButtonBlackTextShadowColor             [NSColor blackColor]

- (id)initWithString:(NSString *)text
{
    self = [super initWithFrame:NSZeroRect];
    if (!self) {
        return nil;
    }
    
    NSShadow *textShadow = [NSShadow new];
    
    [textShadow setShadowOffset:SNRButtonBlackTextShadowOffset];
    [textShadow setShadowColor:SNRButtonBlackTextShadowColor];
    [textShadow setShadowBlurRadius:SNRButtonBlackTextShadowBlurRadius];
    
    _textStorage = [[NSTextStorage alloc] initWithString:text];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [NSColor whiteColor], NSShadowAttributeName: textShadow };
    [_textStorage setAttributes:attributes range:NSMakeRange(0, [text length])];
    
    _layoutManager = [[NSLayoutManager alloc] init];
    _textContainer = [[NSTextContainer alloc] init];
    
    [_layoutManager addTextContainer:_textContainer];
    [_textStorage addLayoutManager:_layoutManager];
    
    // Calculate the size
    [_textContainer setContainerSize:NSMakeSize(FLT_MAX, 12)];
    [_layoutManager glyphRangeForTextContainer:_textContainer];
    NSRect needsRect = [_layoutManager usedRectForTextContainer:_textContainer];
    
    [self setFrameSize:needsRect.size];
    
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [_textContainer setContainerSize:[self bounds].size];
    NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
    [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:[self bounds].origin];
}

@end
