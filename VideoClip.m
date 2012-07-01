//
//  VideoClip.m
//  Flare
//
//  Created by iain on 09/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoClip.h"
#import <QTKit/QTKit.h>


@implementation VideoClip

@synthesize filePath, movie, thumbnail, title;
@synthesize duration;

- (id)initWithFilePath:(NSString *)_filePath title:(NSString *)_title
{
    self = [super init];
    
    [self setFilePath:_filePath];
    [self setTitle:_title];

    return self;
}

- (void)openMovie
{
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    // Disabled QTOpenForPlaybackAttribute as it stops some thumbnails working
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:url, QTMovieURLAttribute,
                          //[NSNumber numberWithBool:YES], QTMovieOpenForPlaybackAttribute,
                          [NSNumber numberWithBool:YES], QTMovieMutedAttribute,
                          [NSNumber numberWithBool:YES], QTMovieLoopsAttribute,
                          nil];
    NSError *error = nil;
    movie = [[QTMovie movieWithAttributes:dict error:&error] retain];
    
    if (error != nil) {
        NSLog(@"Error getting movie: %@", [error localizedDescription]);
    }
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
	// We'll specify a custom size of 95 X 120 for the returned image:
	NSSize imageSize = NSMakeSize(120, 95);
	NSValue *sizeValue = [NSValue valueWithSize:imageSize];
	[attributes setObject:sizeValue forKey:QTMovieFrameImageSize];
    
	/* get the current movie time - we'll pass this value to the
     frameImageAtTime: method below */
    QTTime time = QTMakeTime(5, 1);
    //QTTime time = [movie currentTime];
    
	/* return an NSImage for the frame at the current time in the QTMovie */
	NSImage *th = [movie frameImageAtTime:time
                           withAttributes:attributes
                                    error:&error];
    if (error != nil) {
        NSLog(@"Error making thumbnail: %@", [error localizedDescription]);
        return;
    }
    
    [self setThumbnail:th];
}

- (void)dealloc
{
    [filePath release];
    [movie release];
    [thumbnail release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", filePath];
}

#pragma mark - Accessors

- (void)setFilePath:(NSString *)path
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
    if (movie == nil) {
        NSLog(@"Loading movie for %@", filePath);
        
         NSLog(@"Got movie for %@ - %p", filePath, movie);
    }
    return movie;
}

- (NSImage *)thumbnail
{
    if (!thumbnail) {
        NSLog(@"Thumbnail not ready yet for %@", filePath);
    }
    
    return thumbnail;
}

@end
