//
//  VideoFileController.h
//  Flare
//
//  Created by iain on 31/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CycArrayController.h"

@interface VideoClipController : CycArrayController <NSTableViewDelegate,NSTableViewDataSource> {
@private
    NSMetadataQuery *videoQuery;
}

- (void)dequeueVideoItem;
@end
