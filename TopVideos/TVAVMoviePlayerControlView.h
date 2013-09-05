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
//#import <VevoSDK/VM
//#import "VMVolumeControlView.h"
//#import "VMPlayerOverlayObject.h"
//#import "VMMoviePlayerController.h"
//#import "VMScrubView.h"


//@interface TVAVMoviePlayerControlView : UIView <VMScrubViewDelegate, UIGestureRecognizerDelegate>
@interface TVAVMoviePlayerControlView : UIView <UIGestureRecognizerDelegate>

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

- (void)toggleVolumeControl:(id)sender;

//- (void)toggleShowingOnTV:(BOOL)isOnTV;

/* Show the stop button in the movie player controller. */
-(void)showStopButton;

/* Show the play button in the movie player controller. */
-(void)showPlayButton;

-(void)showBufferingIndicator;

-(void)hideBufferingIndicator;

-(void)enablePlayerButtons;

-(void)disablePlayerButtons;


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
