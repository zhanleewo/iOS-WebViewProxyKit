//
//  AppDelegate.h
//  WebViewProxyDemo
//
//  Created by Rommel on 14/11/28.
//  Copyright (c) 2014年 AOLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CredentialsManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readwrite) CredentialsManager *   credentialsManager;
@end

