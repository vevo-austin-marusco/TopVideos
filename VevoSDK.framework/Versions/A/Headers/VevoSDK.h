//
//  VevoSDK.h
//  vevo-ios-sdk
//
//  Created by Harry Xu on 4/9/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMConstants.h"


@interface VevoSDK : NSObject


+ (void)setVMLoggingLevel:(VMLogLevel)logLevel;

//
// Methods for Enabling VevoSDK
//
// You must call one of these before using any other VevoSDK functionality

+ (void)checkAuthenticationWithClientId:(NSString *)clientId secret:(NSString *)secret completion:(void (^)(BOOL success, NSError *error, id result))completion;


@end
