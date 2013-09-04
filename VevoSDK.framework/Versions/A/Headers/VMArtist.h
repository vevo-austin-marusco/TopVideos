//
//  VMArtist.h
//  vevo-ios-sdk
//
//  Created by Harry Xu on 4/16/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "VMEntityBase.h"

@interface VMArtist : VMEntityBase

@property (nonatomic, strong) NSString  *artistId;
@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *largeImageUrl;
@property (nonatomic, strong) NSString  *formattedViewcount;
@property (nonatomic, strong) NSString  *twitterAccount;
@property (nonatomic, strong) NSString  *songkickId;
@property (nonatomic, strong) NSString  *urlSafeName;
@property (nonatomic, strong) NSString  *homepageUrl;
@property (nonatomic) int               viewCount;
@property (nonatomic) int               videoCount;
@property (nonatomic) int               favoriteCount;
@property (nonatomic) BOOL              isOnTour;
@property (nonatomic, strong) NSString  *fanPageUrl;
@property (nonatomic, strong) NSString  *iTunesUrl;

- (NSMutableDictionary*)toDictionary;

@end
