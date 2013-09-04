//
//  VMConstants.h
//  vevo-ios-sdk
//
//  Created by Harry Xu on 4/14/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//
#import "VMVideo.h"
#import "VMPlaylist.h"

#ifdef __cplusplus
#define VM_EXTERN			extern "C"
#else
#define VM_EXTERN			extern
#endif

typedef enum {
	VM_LOG_LEVEL_QUIET		=	1,
	VM_LOG_LEVEL_INFO		=	7,
	VM_LOG_LEVEL_VERBOSE	=	13
} VMLogLevel;

@protocol MoviePlayerControlViewDelegate
- (NSString*)playlistTitle;
- (void)onTouchPlayer;

@optional
- (VMVideo*)currentVideo;
- (VMPlaylist*)playlist;
- (BOOL)isFullscreen;
- (void)playStateDidChange;
/* The user is dragging the movie controller thumb to scrub through the movie. */
- (void)beginScrubbing;

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (void)endScrubbing;

@end

//MoviePlayer can be embeded inside a container controller, using following methods to inform container movie player events
@protocol VMMoviePlayerContainerDelegate<NSObject>

@required
- (void) moviePlayerDidStop;
@optional
- (void) moviePlayerFailedWithError:(NSError *)error;
- (void) moviePlayerStartPlayingAds;
- (void) moviePlayerEndPlayingAds;
- (void) moviePlayerDidGetRecommendations:(NSArray*)recommendations;
- (void) moviePlayerStartPlayRecommendationAt:(int)index;
- (void) movieplayerReadyToPlayVideo;

@end

