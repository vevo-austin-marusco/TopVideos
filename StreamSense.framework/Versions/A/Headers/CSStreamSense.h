//
//  CSStreamSensePuppet.h
//  ComScore
//
//  Copyright (c) 2011 comScore, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSStreamSense.h"
#import "CSStreamSenseClip.h"
#import "CSStreamSensePlaylist.h"
#import "CSStreamSenseMovieAdapter.h"

typedef enum {
    CSStreamSensePlay,
    CSStreamSenseBuffer,
    CSStreamSensePause,
    CSStreamSenseEnd,
    CSStreamSenseKeepAlive,
    CSStreamSenseHeartbeat,
    CSStreamSenseAdPlay,
    CSStreamSenseAdPause,
    CSStreamSenseAdEnd,
    CSStreamSenseAdClick,
    CSStreamSenseCustom
} CSStreamSenseEventType;

extern NSString* const CSStreamSenseEventType_toString[12];

@interface CSStreamSense : NSObject {
@private
    NSMutableDictionary *persistentLabels;
    NSString *pixelURL;
    CSStreamSenseMovieAdapter *adapter;
    CSStreamSensePlaylist *playlist;
    CSStreamSenseClip *clip;
    CSStreamSenseState currentState;
    CSStreamSenseState prevState;
    CSStreamSenseState lastStateWithMeasurement;
    NSTimer *keepAliveTimer;
    NSTimer *heartbeatTimer;
    NSTimer *pausedOnBufferingTimer;
    NSTimer *delayedTransitionTimer;
    int heartbeatCount;
    NSTimeInterval nextHeartbeatInterval, nextHeartbeatTimestamp;
    NSTimeInterval previousStateTime;
    NSMutableArray *delegates_;
    
    NSString *mediaPlayerName, *mediaPlayerVersion;
    NSMutableDictionary *measurementSnapshot;
    
    long lastKnownPosition;
    int nextEventCount;
    
    BOOL engaged;
}

-(id) init;

@property (assign) BOOL sharingSDKPersistentLabels;
@property (assign) BOOL sendPauseOnRebuffering;
@property (assign) BOOL pausePlaySwitchDelayEnabled;

+(CSStreamSense *) analyticsForMoviePlayer: (MPMoviePlayerController*) moviePlayerController;
+(CSStreamSense *) analyticsWithEssentialNotificationsForMoviePlayer: (MPMoviePlayerController*) moviePlayerController;
+(CSStreamSense *) analyticsForMoviePlayer: (MPMoviePlayerController*) moviePlayerController andLabels:(NSDictionary *) labels;
+(CSStreamSense *) analyticsWithEssentialNotificationsForMoviePlayer: (MPMoviePlayerController*) moviePlayerController andLabels:(NSDictionary *) labels;

-(void) setLabel: (NSString *) name withValue:(NSString *)value;
-(void) setLabels: (NSDictionary *) dictionary;
-(NSString *) getLabel: (NSString *) name;
-(NSDictionary *) getLabels;
-(void) reset;
-(void) reset:(NSArray*) keepLabels;

-(bool) notify: (CSStreamSenseEventType) playerEvent withPosition:(long)ms;
-(bool) notify: (CSStreamSenseEventType) playerEvent withPosition:(long)ms withLabels: (NSDictionary *) labels;

-(void) setClip: (NSDictionary *) labels;
-(void) setClip: (NSDictionary *) labels withPlaylistLoop:(BOOL)loop;
-(void) setPlaylist: (NSDictionary *) labels;

-(void) importState:(NSDictionary *) labels;
-(NSDictionary *) exportState;

-(void) engagePuppetMode;
-(void) engageMoviePlayer: (MPMoviePlayerController*) moviePlayerController;

-(void) disengage;
-(NSString *) getVersion;

-(NSString *) setPixelURL: (NSString *) value;

@end
