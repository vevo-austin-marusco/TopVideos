//
//  VMVideo.h
//  vevo-ios-sdk
//
//  Created by Harry Xu on 4/9/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "VMEntityBase.h"

@class VMRendition;

@interface VMVideo : VMEntityBase

// Video URLs
@property (nonatomic, strong) NSURL         *webURL;
@property (nonatomic, strong) NSURL         *shortURL;

// Basic info
@property (nonatomic, strong) NSString      *isrc;
@property (nonatomic, strong) NSString      *title;
@property (nonatomic, strong) NSString      *urlSafeTitle;


@property (nonatomic, strong) NSArray       *renditions;
@property (nonatomic, strong) NSString      *streamingType;

@property (nonatomic, strong) NSString      *genreKey;
@property (nonatomic, strong) NSString      *genre;

// Extended Info
@property (nonatomic, assign) BOOL          isLive;
@property (nonatomic, assign) BOOL          hasMultipleRendition;
@property (nonatomic, assign) BOOL          hasMultipleCameraAngles;
@property (nonatomic) BOOL                  isPremiere;
@property (nonatomic) BOOL                  isExplicit;
@property (nonatomic) BOOL                  isExtended;
@property (nonatomic) BOOL                  isLiveStream;
@property (nonatomic) BOOL                  monetizeBetweenRenditionSwitch;

@property (nonatomic, assign) int           currentRenditionIndex;
@property (nonatomic) int                   duration;
@property (nonatomic) int                   viewcount;
@property (nonatomic, strong) NSString      *formattedViewcount;

@property (nonatomic, strong) NSString      *director;
@property (nonatomic, strong) NSString      *composer;
@property (nonatomic, strong) NSString      *recordLabel;
@property (nonatomic, strong) NSString      *moreInfoImageUrl;

// Artist strings
@property (nonatomic, strong) NSString      *artist;  // the artist(s) of this video represented in the way of "main artist ft. featured artist
@property (nonatomic, strong) NSString      *mainArtist;
@property (nonatomic, strong) NSString      *mainArtistId;
@property (nonatomic, strong) NSString      *mainArtistUrlSafename;
@property (nonatomic, strong) NSString      *featuredArtist;

@property (nonatomic, strong) NSArray       *credits;
@property (nonatomic, strong) NSArray       *parsedCredits;

// External links related to this video
@property (nonatomic, strong) NSURL         *amazonzBuyLink;
@property (nonatomic, strong) NSURL         *itunesBuyLink;
@property (nonatomic, strong) NSURL         *songkickBuyLink;
@property (nonatomic, strong) NSURL         *bravadoBuyLink;

@property (nonatomic, readonly) double      latitude;
@property (nonatomic, readonly) double      longitude;




- (NSString*)infoViewImageURL;
- (NSString*)previewImageURL;
- (NSString*)categoryImageURL;
- (NSDictionary*)toDictionary;
- (NSURL*)currentStreamURL;
- (void)extendVideoWithDictionary:(NSDictionary *)dictionary;
- (NSString*)getArtistsString:(NSArray*)artistDictionaryArray;
- (void)parseURLs;


@end
