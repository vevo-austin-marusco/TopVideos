//
//  VMRendition.h
//  vevo-ios-sdk
//
//  Created by Harry Xu on 4/9/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "VMEntityBase.h"

@interface VMRendition : VMEntityBase

@property (weak, nonatomic, readonly) NSString    *name;
@property (weak, nonatomic, readonly) NSURL       *url;
@property (weak, nonatomic, readonly) NSString    *thumbnail;
@property (nonatomic, strong) NSURL         *streamUrl;
@property (weak, nonatomic, readonly) NSURL       *thumbnailUrl;
@property (nonatomic, readonly) int         thumbnailUpdateInterval;

@end
