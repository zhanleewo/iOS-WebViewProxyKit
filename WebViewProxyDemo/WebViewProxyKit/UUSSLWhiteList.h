//
//  UUSSLWhiteList.h
//  WebViewProxyDemo
//
//  Created by Rommel on 14/11/28.
//  Copyright (c) 2014年 AOLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UUSSLWhiteList : NSObject
{
@private
    NSMutableArray *_whiteList;
}

+ (instancetype) sharedSSLWhiteList;

- (void) addIgonerURL:(NSURL *) url;
- (void) addIgonerHost:(NSString *) host;


- (BOOL) hostIsContainedInWhiteList:(NSString *) host;
- (BOOL) urlIsContainedInWhiteList:(NSURL *) url;

@end