//
//  CursorLayer.h
//  Cyclorama
//
//  Created by iain on 28/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CursorLayer : CALayer

@property (readwrite, nonatomic) BOOL showCursor;
@property (readwrite, nonatomic) CGFloat cursorPosition;

@end
