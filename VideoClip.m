//
//  VideoClip.m
//  Flare
//
//  Created by iain on 09/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoClip.h"


@implementation VideoClip

@synthesize filePath, movie, thumbnail, title;
@synthesize duration;

- (id)initWithMovie:(QTMovie *)_movie
{
    self = [super init];
    
    movie = [_movie retain];
    
    return self;
}

- (void)dealloc
{
    [filePath release];
    [movie release];
    [thumbnail release];
    [super dealloc];
}

#pragma mark - Accessors

- (void)filePath:(NSString *)path
{
    if (path == filePath) {
        return;
    }
    
    if (filePath) {
        [filePath release];
    }
    
    filePath = path;
    [filePath retain];
}

- (QTMovie *)movie
{
    return movie;
}

- (NSImage *)thumbnail
{
    if (!thumbnail) {
        QTMovie *_movie = [self movie];
        thumbnail = [_movie posterImage];
    }
    
    return thumbnail;
}

#pragma mark - Notifications

- (void)movieLoadStateDidChange:(NSNotification *)note
{
    NSNumber *loadState = [movie attributeForKey:QTMovieLoadStateAttribute];
    NSLog(@"%@ Load State Changed: %ld", filePath, [loadState longValue]);
}
@end
