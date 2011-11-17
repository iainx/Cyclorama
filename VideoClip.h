//
//  VideoClip.h
//  Flare
//
//  Created by iain on 09/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

@interface VideoClip : NSObject {
@private
    QTMovie *movie;
    NSImage *thumbnail;
    QTTime duration;
}

- (id)initWithMovie:(QTMovie *)movie;

@property (nonatomic, readwrite, retain) NSString *filePath;
@property (nonatomic, readwrite, retain) NSString *title;
@property (readonly) QTMovie *movie;
@property (readonly) NSImage *thumbnail;
@property (readonly) QTTime duration;
@end
