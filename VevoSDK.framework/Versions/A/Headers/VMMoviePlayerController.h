//
//  VMMoviePlayerController.h
//  vevo-ios-sdk
//
//  Created by Harry Xu on 7/2/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "VMVideo.h"
#import "VMConstants.h"
#import "VMPlayerOverlayObject.h"

typedef enum  {
    VMMoviePlaybackStateStopped = 0,
    VMMoviePlaybackStatePlaying,
    VMMoviePlaybackStatePaused,
    VMMoviePlaybackStateInterrupted,
    VMMoviePlaybackStateSeekingForward,
    VMMoviePlaybackStateSeekingBackward
} VMMoviePlaybackState;

typedef enum {
    VMMovieControlStyleNone,
    VMMovieControlStyleEmbedded,
    VMMovieControlStyleFullscreen,
    VMMovieControlStyleDefault = VMMovieControlStyleFullscreen
} VMMovieControlStyle;

@interface VMMoviePlayerController : NSObject< MoviePlayerControlViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView              *baseView;

/**
 *  Current video that is being played.
 */
@property (nonatomic, strong) VMVideo           *video;

/**
 *  Current playlist title.
 */
@property (nonatomic, strong) NSString          *playlistTitle;


@property (nonatomic, weak) id<VMMoviePlayerContainerDelegate>         containerDelegate;

/*!
 @property controlStyle An enum value providing the player control style.
 */
@property (nonatomic) VMMovieControlStyle         controlStyle;

/*!
 @property playerState An enum value providing the current player state.
 */
@property (nonatomic) VMMoviePlaybackState   playerbackState;

/*!
 @property The duration of the movie, or 0.0 if not known.
 */
@property(nonatomic, readonly) NSTimeInterval duration;

/*!
 @property The amount of currently playable content, reflects the amount of content that can be played now.
 */
@property(nonatomic, readonly) NSTimeInterval playableDuration;

/*!
 @property The amount of currently playable content, reflects the amount of content that can be played now.
 */
@property(nonatomic) NSTimeInterval controlViewFadeoutDuration;


/*!
 @property A Boolean value that determines whether continue play recommendation videos.
 @discussion Setting the value of this property to YES will not continue play recommendation videos. The default value is NO.
 */
@property (nonatomic) BOOL   disableContinuousPlay;

/*!
 @property A Boolean value that determines whether AirPlay available.
 */
@property (nonatomic, readonly) BOOL   isAirPlayAvailable;


- (id)initWithBaseView:(UIView *)baseView;

/*!
 @method - (void)stop
 @discussion Call this method to stop video ( by user)
 */
- (void)stopPlayer;

/*!
 @method - (void)startTVPlayer
 @discussion Call this method when user start playing video.
 */
- (void)startPlayer;

/*!
 @method - (void)resumeTVPlayer
 @discussion Call this method to resume the player after pausing it.
 */
- (void)resumePlayer;

/*!
 @method - (void)pauseTVPlayer
 @discussion Call this method to pause the player.
 */
- (void)pausePlayer;


- (BOOL)isPlaying;


- (BOOL)isAirPlayVideoActive;
/*!
 @method - (void)stop
 @discussion Get the the current time of the current item.
 */
- (NSTimeInterval) currentTime;

/*!
 @method - (void)stop
 @discussion Moves the playback cursor to a given time.
 */
- (void) seekToTime:(NSTimeInterval)time;


- (void)playVideo:(VMVideo *)video;
- (void)playPlaylist:(VMPlaylist *)sourcePlaylist startingIndex:(int)index;
- (void)playRecommendationAtIndex:(int)index;
- (void)playNextVideo;
- (void)playPreviousVideo;
//- (void)adjustPlayerSize;
- (void)showOverlay:(id<VMPlayerOverlayObject>)overlayView;


-(id)registerPlayerTimeObserverWithInterval:(double)interval callbackBlock:(void(^)(CMTime time))cb;

-(void)unregisterPlayerTimeObserver:(id)timeObserver;

@end
