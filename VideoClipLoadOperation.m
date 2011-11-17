//
//  VideoClipLoadOperation.m
//  Cyclorama
//
//  Created by Iain Holmes on 08/11/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import "VideoClipLoadOperation.h"
#import <QTKit/QTKit.h>

@implementation VideoClipLoadOperation

@synthesize url;
@synthesize movie;

- (id)initWithMovie:(QTMovie *)_movie 
             forURL:(NSURL *)_url
   completeDelegate:(id)completeDelegate
   completeSelector:(SEL)completeSelector
{
    self = [super init];
    movie = [_movie retain];
    url = [_url retain];

    delegate = completeDelegate;
    selector = completeSelector;
    
    return self;
}

- (void)dealloc
{
    [movie release];
    [url release];
    
    [super dealloc];
}

- (void) main
{
    NSLog(@"Starting to load %@", [url description]);
    
    [QTMovie enterQTKitOnThread];
    [movie attachToCurrentThread];
    
    [movie setAttribute:url forKey:QTMovieURLAttribute];
    
    [movie detachFromCurrentThread];
    [QTMovie exitQTKitOnThread];
    
    NSLog(@"Loaded %@", [url description]);
    
    if (delegate && selector && [delegate respondsToSelector:selector]) {
        [delegate performSelectorOnMainThread:selector
                                   withObject:movie
                                waitUntilDone:YES];
    }
}
@end
