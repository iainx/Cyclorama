//
//  CycParameterViewController.h
//  FilterUIViewTest
//
//  Created by Iain Holmes on 09/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CycParameterViewController : NSViewController

@property (copy) NSString *name;
@property (readwrite, copy) NSString *paramName;
- (void)setAttributes:(NSDictionary *)attrs;

@end
