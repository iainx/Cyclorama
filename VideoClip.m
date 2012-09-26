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

    //[self openMovie];
    
    return self;
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
                                  return;
                              }
                              
                              NSError *error = nil;
                              AVKeyValueStatus status = [[self asset] statusOfValueForKey:@"tracks"
                                                                                    error:&error];
                              switch (status) {
                                  case AVKeyValueStatusLoaded:
                                      // Now we can get the thumbnail
                                      if ([[self asset] tracksWithMediaCharacteristic:AVMediaTypeVideo]) {
                                          [self createThumbnailImage];
                                      }
                                      break;
                                      
                                  case AVKeyValueStatusFailed:
                                      // Error out
                                      NSLog(@"Error loading %@: %@", [self filePath], [error localizedDescription]);
                                      break;
                                      
                                  default:
                                      break;
                              }
                              
                          }];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self filePath]];
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
        NSImage *tn = [[NSImage alloc] initWithCGImage:t
                                                  size:NSZeroSize];
        [self setThumbnail:tn];
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
        NSLog(@"No movie for %@", [self filePath]);
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
    
    // We have no thumbnail
    // FIXME: should return a status to say whether we're waiting for the thumbnail
    // or we can't provide a thumbnail
    return NO;
}
@end
