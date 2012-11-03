//
//  SwizzleStick.m
//  Cyclorama
//
//  Created by iain on 03/11/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "SwizzleStick.h"
#import <objc/runtime.h>
#import <objc/message.h>

/*
void Swizz (Class c, SEL orig, SEL replace)
{
    Method origMethod = class_getClassMethod(c, orig);
    Method newMethod = class_getClassMethod(c, replace);
    
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, replace, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        class_replaceMethod(c, replace, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
}

*/