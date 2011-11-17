//
//  VideoFileController.h
//  Flare
//
//  Created by iain on 31/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VideoClipController : NSArrayController <NSTableViewDelegate,NSTableViewDataSource> {
@private
    NSMetadataQuery *videoQuery;
    
    NSOperationQueue *clipLoaderQueue;
}

@end
