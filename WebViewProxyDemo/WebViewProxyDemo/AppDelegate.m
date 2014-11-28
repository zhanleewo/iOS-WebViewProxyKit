//
//  AppDelegate.m
//  WebViewProxyDemo
//
//  Created by Rommel on 14/11/28.
//  Copyright (c) 2014年 AOLC. All rights reserved.
//

#import "AppDelegate.h"

#import "CustomHTTPProtocol.h"

@interface AppDelegate () <CustomHTTPProtocolDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
//    NSDictionary *dict = @{
//                           @"SOCKSEnable" : @1,
//                           @"SOCKSProxy" : @"127.0.0.1",
//                           @"SOCKSPort" : @1080,
//                           @"SOCKSProxyAuthenticated" : @0,
//                           };
//
//    [CustomHTTPProtocol setProxyConfig:dict];
//    self.credentialsManager = [[CredentialsManager alloc] init];
//    [CustomHTTPProtocol setDelegate:self];
//    if (YES) {
//        [CustomHTTPProtocol start];
//    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



/*! Called by an CustomHTTPProtocol instance to ask the delegate whether it's prepared to handle
 *  a particular authentication challenge.  Can be called on any thread.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param protectionSpace The protection space for the authentication challenge; will not be nil.
 *  \returns Return YES if you want the -customHTTPProtocol:didReceiveAuthenticationChallenge: delegate
 *  callback, or NO for the challenge to be handled in the default way.
 */

- (BOOL)customHTTPProtocol:(CustomHTTPProtocol *)protocol canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    assert(protocol != nil);
#pragma unused(protocol)
    assert(protectionSpace != nil);
    
    return [[protectionSpace authenticationMethod] isEqual:NSURLAuthenticationMethodServerTrust];
}

/*! Called by an CustomHTTPProtocol instance to request that the delegate process on authentication
 *  challenge. Will be called on the main thread. Unless the challenge is cancelled (see below)
 *  the delegate must eventually resolve it by calling -resolveAuthenticationChallenge:withCredential:.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param challenge The authentication challenge; will not be nil.
 */

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    OSStatus            err;
    NSURLCredential *   credential;
    SecTrustRef         trust;
    SecTrustResultType  trustResult;
    
    // Given our implementation of -customHTTPProtocol:canAuthenticateAgainstProtectionSpace:, this method
    // is only called to handle server trust authentication challenges.  It evaluates the trust based on
    // both the global set of trusted anchors and the list of trusted anchors returned by the CredentialsManager.
    
    assert(protocol != nil);
    assert(challenge != nil);
    assert([[[challenge protectionSpace] authenticationMethod] isEqual:NSURLAuthenticationMethodServerTrust]);
    assert([NSThread isMainThread]);
    
    credential = nil;
    
    // Extract the SecTrust object from the challenge, apply our trusted anchors to that
    // object, and then evaluate the trust.  If it's OK, create a credential and use
    // that to resolve the authentication challenge.  If anything goes wrong, resolve
    // the challenge with nil, which continues without a credential, which causes the
    // connection to fail.
    
    trust = [[challenge protectionSpace] serverTrust];
    if (trust == NULL) {
        assert(NO);
    } else {
        err = SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef) self.credentialsManager.trustedAnchors);
        if (err != noErr) {
            assert(NO);
        } else {
            err = SecTrustSetAnchorCertificatesOnly(trust, false);
            if (err != noErr) {
                assert(NO);
            } else {
                err = SecTrustEvaluate(trust, &trustResult);
                if (err != noErr) {
                    assert(NO);
                } else {
                    if ( (trustResult == kSecTrustResultProceed) || (trustResult == kSecTrustResultUnspecified) ) {
                        credential = [NSURLCredential credentialForTrust:trust];
                        assert(credential != nil);
                    }
                    //credential = [NSURLCredential credentialForTrust:trust];
                }
            }
        }
    }
    
    [protocol resolveAuthenticationChallenge:challenge withCredential:credential];
}

/*! Called by an CustomHTTPProtocol instance to cancel an issued authentication challenge.
 *  Will be called on the main thread.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param challenge The authentication challenge; will not be nil; will match the challenge
 *  previously issued by -customHTTPProtocol:canAuthenticateAgainstProtectionSpace:.
 */

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
}

/*! Called by the CustomHTTPProtocol to log various bits of information.
 *  Can be called on any thread.
 *  \param protocol The protocol instance itself; nil to indicate log messages from the class itself.
 *  \param format A standard NSString-style format string; will not be nil.
 *  \param arguments Arguments for that format string.
 */

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol logWithFormat:(NSString *)format arguments:(va_list)arguments {
    
    return;
    
    NSString *  prefix;
    
    // protocol may be nil
    assert(format != nil);
    
    if (protocol == nil) {
        prefix = @"protocol ";
    } else {
        prefix = [NSString stringWithFormat:@"protocol %p ", protocol];
    }
    [self logWithPrefix:prefix format:format arguments:arguments];
}


- (void)logWithPrefix:(NSString *)prefix format:(NSString *)format arguments:(va_list)arguments
{
    assert(prefix != nil);
    assert(format != nil);
    NSString *body = [[NSString alloc] initWithFormat:format arguments:arguments];
    NSLog(@"%@ - %@", prefix, body);
    //    if (sAppDelegateLoggingEnabled) {
    //        NSTimeInterval  now;
    //        ThreadInfo *    threadInfo;
    //        NSString *      str;
    //        char            elapsedStr[16];
    //
    //        now = [NSDate timeIntervalSinceReferenceDate];
    //
    //        threadInfo = [self threadInfoForCurrentThread];
    //
    //        str = [[NSString alloc] initWithFormat:format arguments:arguments];
    //        assert(str != nil);
    //
    //        snprintf(elapsedStr, sizeof(elapsedStr), "+%.1f", (now - sAppStartTime));
    //
    //        fprintf(stderr, "%3zu %s %s%s\n", (size_t) threadInfo.number, elapsedStr, [prefix UTF8String], [str UTF8String]);
    //    }
}

@end
