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

static NSOperationQueue *loadThumbnailQueue = nil;

+ (void)initialize
{
    if (loadThumbnailQueue == nil) {
        loadThumbnailQueue = [[NSOperationQueue alloc] init];
        [loadThumbnailQueue setMaxConcurrentOperationCount:1];
        [loadThumbnailQueue setName:@"Thumbnailer"];
    }
}

- (id)initWithFilePath:(NSString *)_filePath title:(NSString *)_title
{
    self = [super init];
    
    [self setFilePath:_filePath];
    [self setTitle:_title];

    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:url, QTMovieURLAttribute,
                          [NSNumber numberWithBool:YES], QTMovieMutedAttribute,
                          [NSNumber numberWithBool:YES], QTMovieOpenAsyncRequiredAttribute, nil];
    NSError *error = nil;
    movie = [[QTMovie movieWithAttributes:dict error:&error] retain];
    if (error != nil) {
        NSLog(@"Error getting movie: %@", [error localizedDescription]);
    }
    [movie detachFromCurrentThread];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(movieLoadStateChanged:) 
               name:QTMovieLoadStateDidChangeNotification
             object:movie];

    return self;
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

#pragma mark - Notifications

- (void)loadThumbnail
{
    NSImage *t;
    
    NSLog(@"Loading thumbnail for %@", filePath);
    
    [QTMovie enterQTKitOnThread];
    if ([movie attachToCurrentThread] == NO) {
        NSLog(@"Error attaching to operation thread");
    }
    
    t = [movie posterImage];
    
    
    if ([movie detachFromCurrentThread] == NO) {
        NSLog(@"Error detaching from operation thread");
    }
    [QTMovie exitQTKitOnThread];
    
    NSLog(@"Setting thumbnail %p for %@", t, filePath);
    [self performSelectorOnMainThread:@selector(setThumbnail:) withObject:t waitUntilDone:YES];
    NSLog(@"setThumbnail complete for %@", filePath);
}

- (void)movieLoadStateChanged:(NSNotification *)note
{
    QTMovie *m = [note object];
    
    NSNumber *state = [m attributeForKey:QTMovieLoadStateAttribute];;
    NSLog(@"Load state changed to: %ld for %@", [state longValue], filePath);
    
    if ([state longValue] > QTMovieLoadStatePlayable) {
        NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self
                                                                         selector:@selector(loadThumbnail)
                                                                           object:nil];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:CYCVideoClipReady object:self];
        
        [loadThumbnailQueue addOperation:op];
    } else if ([state longValue] == -1L) {
        [self release];
    }
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
