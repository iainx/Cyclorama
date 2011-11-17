//
//  VideoClipCell.h
//  Cyclorama
//
//  Created by Iain Holmes on 13/09/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <AppKit/AppKit.h>

@interface VideoClipCell : NSTextFieldCell {
@private
    NSString *subtitle;
    NSImage *thumbnail;
}

@property (readwrite, copy) NSString *subtitle;
@property (readwrite, retain) NSImage *thumbnail;
@end
