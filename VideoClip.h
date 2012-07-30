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

- (id)initWithFilePath:(NSString *)_filePath title:(NSString *)_title;

@property (nonatomic, readwrite, strong) NSString *filePath;
@property (nonatomic, readwrite, strong) NSString *title;
@property (readonly) QTMovie *movie;
@property (readwrite, strong) NSImage *thumbnail;
@property (readonly) QTTime duration;

- (void)openMovie;
@end
