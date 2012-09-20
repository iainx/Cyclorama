//
//  VideoClip.h
//  Flare
//
//  Created by iain on 09/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoClip : NSObject

@property (nonatomic, readwrite, strong) NSString *filePath;
@property (nonatomic, readwrite, strong) NSString *title;
@property (readonly, strong, nonatomic) AVURLAsset *asset;
@property (readwrite, strong) NSImage *thumbnail;
@property (readonly) CMTime duration;

- (id)initWithFilePath:(NSString *)filePath title:(NSString *)title;
- (void)openMovie;
- (BOOL)requestThumbnail;

@end
