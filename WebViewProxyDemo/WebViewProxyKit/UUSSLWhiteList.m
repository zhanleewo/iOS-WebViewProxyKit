//
//  UUSSLWhiteList.m
//  WebViewProxyDemo
//
//  Created by Rommel on 14/11/28.
//  Copyright (c) 2014年 AOLC. All rights reserved.
//

#import "UUSSLWhiteList.h"

@implementation UUSSLWhiteList
- (instancetype) init {
    if(self = [super init]) {
        _whiteList = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

+ (instancetype) sharedSSLWhiteList {
    static UUSSLWhiteList *_sSSLWhiteList = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sSSLWhiteList = [[UUSSLWhiteList alloc] init];
    });
    return _sSSLWhiteList;
}

- (void) addIgonerURL:(NSURL *) url
{
    if(![self urlIsContainedInWhiteList:url]) {
        if(url == nil) return;
        if(url.host == nil || url.host.length == 0) return;
        [_whiteList addObject:url.host];
    }
}

- (void) addIgonerHost:(NSString *) host
{
    if(![self hostIsContainedInWhiteList:host]) {
        if(host == nil || host.length == 0) return;
        [_whiteList addObject:host];
    }
}

- (BOOL) hostIsContainedInWhiteList:(NSString *) host
{
    if(host == nil || host.length == 0) return NO;
    return [_whiteList containsObject:host];
}


- (BOOL) urlIsContainedInWhiteList:(NSURL *) url
{
    if(url == nil) return NO;
    if(url.host == nil || url.host.length == 0) return NO;
    
    return [_whiteList containsObject:url.host];
}

@end

