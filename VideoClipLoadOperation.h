//
//  VideoClipLoadOperation.h
//  Cyclorama
//
//  Created by Iain Holmes on 08/11/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Foundation/Foundation.h>

@class QTMovie;

@interface VideoClipLoadOperation : NSOperation {
    SEL selector;
    id delegate;
}

@property (readwrite, strong) NSURL *url;
@property (readwrite, strong) QTMovie *movie;

- (id)initWithMovie:(QTMovie *)_movie 
             forURL:(NSURL *)_url
   completeDelegate:(id)completeDelegate
   completeSelector:(SEL)completeSelector;
@end
