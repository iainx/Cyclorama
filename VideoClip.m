//
//  VideoClip.m
//  Cyclorama
//
//  Created by iain on 09/06/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import "VideoClip.h"

@implementation VideoClip {
    BOOL needThumbnailWhenValueLoaded;
}

@synthesize asset = _asset;

- (id)initWithFilePath:(NSString *)filePath
                 title:(NSString *)title
{
    self = [super init];
    
    [self setFilePath:filePath];
    [self setTitle:title];
    
    needThumbnailWhenValueLoaded = YES;
    
    return self;
}

- (NSImage *)createFailImage
{
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(1.0, 1.0)];
    
    [image lockFocus];
    [[NSColor greenColor] setFill];
    NSRectFill(NSMakeRect(0, 0, 1, 1));
    [image unlockFocus];

    return image;
}

- (void)openMovie
{
    NSURL *url = [NSURL fileURLWithPath:[self filePath]];
    
    _asset = [AVURLAsset URLAssetWithURL:url
                                 options:nil];

    // FIXME: Should we be using a weak ref self here?
    NSArray *keys = @[ @"tracks", @"duration" ];
    [_asset loadValuesAsynchronouslyForKeys:keys
                          completionHandler:^{
                              
                              if (needThumbnailWhenValueLoaded == NO) {
                                  NSLog(@"%@ didn't need thumbnail", url);
                                  return;
                              }
                              
                              NSError *error = nil;
                              AVKeyValueStatus status = [[self asset] statusOfValueForKey:@"tracks"
                                                                                    error:&error];
                              switch (status) {
                                  case AVKeyValueStatusLoaded:
                                  {
                                      // Now we can get the thumbnail
                                      if ([[self asset] tracksWithMediaCharacteristic:AVMediaTypeVideo]) {
                                          [self createThumbnailImage];
                                      } else {
                                          NSImage *image = [self createFailImage];
                                          NSLog(@"%@ didn't have video track", url);
                                          [self updateThumbnailOnMainThread:image];
                                      }
                                      
                                      break;
                                  }

                                  case AVKeyValueStatusFailed:
                                  {
                                      NSImage *image = [self createFailImage];
                                      NSLog(@"%@ KV status failed", url);
                                      [self updateThumbnailOnMainThread:image];
                                      break;
                                  }

                                  default:
                                  {
                                      NSLog(@"%@ Default error: %ld", url, status);
                                      break;
                                  }
                              }
                          }];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self filePath]];
}

- (void)updateThumbnailOnMainThread:(NSImage *)tn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setThumbnail:tn];
    });
}

- (void)createThumbnailImage
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        AVAssetImageGenerator *gen = [AVAssetImageGenerator assetImageGeneratorWithAsset:[self asset]];
        NSError *error = nil;
        
        [gen setMaximumSize:CGSizeMake(150, 150)];
        CMTime frameTime = CMTimeMakeWithSeconds(5.0, 600);
        CMTime actualTime;
        
        CGImageRef t = [gen copyCGImageAtTime:frameTime
                                   actualTime:&actualTime
                                        error:&error];
        
        NSImage *tn;
        if (error != nil) {
            tn = [self createFailImage];
            NSLog(@"%@ error from Image Generator: %@", [[self asset] URL], [error localizedDescription]);
        } else {
            tn = [[NSImage alloc] initWithCGImage:t
                                             size:NSZeroSize];
        }
        [self updateThumbnailOnMainThread:tn];
    });
}
#pragma mark - Accessors

- (void)setFilePath:(NSString *)path
{
    if (path == _filePath) {
        return;
    }
    
    
    _filePath = path;
}

- (AVAsset *)asset
{
    if (_asset == nil) {
        //NSLog(@"No movie for %@", [self filePath]);
        return nil;
    }
    
    return _asset;
}

- (BOOL)requestThumbnail
{
    if (_thumbnail) {
        return YES;
    }

    if ([self asset] == nil) {
        needThumbnailWhenValueLoaded = YES;
        return NO;
    }
    
    NSError *error = nil;
    AVKeyValueStatus status = [[self asset] statusOfValueForKey:@"tracks"
                                                          error:&error];
    
    if (status != AVKeyValueStatusLoaded) {
        // Load the thumbnail whenever the tracks value is loaded
        needThumbnailWhenValueLoaded = YES;
        return NO;
    }
    
    if ([[self asset] tracksWithMediaCharacteristic:AVMediaTypeVideo]) {
        [self createThumbnailImage];
        return NO;
    }
    
    NSLog(@"%@ thumbnail create fail", [_asset URL]);
    // We have no thumbnail so set a broken image
    _thumbnail = [self createFailImage];
    
    return YES;
}
@end
