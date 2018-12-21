//
//  WXObject.m
//  RunLoopDemo
//
//  Created by 王鑫 on 2018/12/21.
//  Copyright © 2018 wangxin. All rights reserved.
//

#import "WXObject.h"

static NSThread *thread = nil;
/** 是否继续事件循环*/
static BOOL runAlways = YES;

@implementation WXObject

+ (NSThread *)threadForDispatch {
    
    if (thread == nil) {
        @synchronized (self) {
            if (thread == nil) {
                thread = [[NSThread alloc] initWithTarget:self selector:@selector(runRequest) object:nil];
                [thread setName:@"alwaysThread"];
                //启动线程
                [thread start];
            }
        }
    }
    
    return thread;
}

+ (void)runRequest {
    
    //创建一个Source
    CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    
    //创建RunLoop，同时向RunLoop的defaultMode下面添加Source
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    
    //如果可以运行
    while (runAlways) {
        @autoreleasepool {
            //令当前RunLoop运行在defaultMode下
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, true);
        }
    }
    
    //某一时机，静态变量runAlways变为NO时，保证跳出RunLoop，线程推出
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
}

@end
