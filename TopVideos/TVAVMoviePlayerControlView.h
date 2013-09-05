//
//  TVAVMoviePlayerControlView.h
//  TopVideos
//
//  Created by New Admin User on 9/5/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VevoSDK/VMMoviePlayerController.h>
#import <VevoSDK/VMPlayerOverlayObject.h>
#import "TVScrubView.h"


@interface TVAVMoviePlayerControlView : UIView <TVScrubViewDelegate, UIGestureRecognizerDelegate,VMPlayerOverlayObject>
@property (nonatomic, weak) VMMoviePlayerController *player;
@property (nonatomic, strong) UIImageView *tvConnectedImageView;
@property (nonatomic, readwrite) BOOL           isOnScreen;
@property (nonatomic, readwrite) NSTimeInterval scrubValue;
@property (nonatomic, readwrite) BOOL           enableScrubber;


//Public methods
//- (void)showControlBar;
//
//- (void)adjustControlBar;

- (void)togglePlayPause:(id)sender;

//- (void)toggleShowingOnTV:(BOOL)isOnTV;

/* Show the stop button in the movie player controller. */
-(void)showStopButton;

/* Show the play button in the movie player controller. */
-(void)showPlayButton;
-(void)showBufferingIndicator;
-(void)hideBufferingIndicator;
-(void)enablePlayerButtons;
-(void)disablePlayerButtons;

/*
 Overlay object functions
 */
- (float)fadeOutSeconds;
- (VMOverlayType) overlayType;
- (BOOL)showOnTouch;
- (BOOL)isShowing;
-(void)transitionIn;
-(void)transitionOut;

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer;

/*
 Cancel the ongoing task such as waiting for fade out.
 */
- (void)cancelOngoingTasks;
- (void)elapsedTimeChanged;



@end
