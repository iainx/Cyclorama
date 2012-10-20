//
//  SLFButton.h
//  Cyclorama
//
//  Created by iain on 14/10/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SLFToolbarButton : NSButton

- (id)initWithTitle:(NSString *)title
             action:(SEL)action
             target:(id)target;
@end
