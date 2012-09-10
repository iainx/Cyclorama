//
//  VideoClip.m
//  Cyclorama
//
//  Created by iain on 09/06/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import "VideoClip.h"

@implementation VideoClip

@synthesize asset = _asset;

- (id)initWithFilePath:(NSString *)filePath
                 title:(NSString *)title
{
    self = [super init];
    
    [self setFilePath:filePath];
    [self setTitle:title];

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
                              NSError *error = nil;
                              AVKeyValueStatus status = [[self asset] statusOfValueForKey:@"tracks"
                                                                                    error:&error];
                              switch (status) {
                                  case AVKeyValueStatusLoaded:
                                      // Now we can get the thumbnail
                                      if ([[self asset] tracksWithMediaCharacteristic:AVMediaTypeVideo]) {
                                          AVAssetImageGenerator *gen = [AVAssetImageGenerator assetImageGeneratorWithAsset:[self asset]];
                                          
                                          [gen setMaximumSize:CGSizeMake(150, 150)];
                                          CMTime frameTime = CMTimeMakeWithSeconds(5.0, 600);
                                          CMTime actualTime;
                                          
                                          CGImageRef t = [gen copyCGImageAtTime:frameTime
                                                                     actualTime:&actualTime
                                                                          error:&error];
                                          NSImage *tn = [[NSImage alloc] initWithCGImage:t
                                                                                    size:NSZeroSize];
                                          [self setThumbnail:tn];
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

@end
