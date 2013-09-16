//
//  CSStreamSenseMovieAdapter.h
//  ComScore
//
//  Copyright (c) 2011 comScore, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class CSStreamSense;

@interface CSStreamSenseMovieAdapter : NSObject {
@private
    CSStreamSense *parent;
    bool delayedStart;
    bool wasSeeking;
    NSMutableDictionary *labels;
}

@property (nonatomic, retain) MPMoviePlayerController *object;

-(id) initWithParent: (CSStreamSense *) parent andMoviePlayer: (MPMoviePlayerController *) moviePlayer;

-(NSTimeInterval) positionTime;
-(NSString *) position;
-(NSString *) duration;
-(NSString *) volume;
-(NSString *) dimensions;
-(NSString *) contentURL;
-(NSString *) playerType;
-(NSString *) playerVersion;
-(NSString *) orientation;
-(NSString *) scalingMode;
-(bool) isLive;

-(NSMutableDictionary *) packLabels;

-(void) receiveScalingModeChange: (NSNotification *) notification;

@end
