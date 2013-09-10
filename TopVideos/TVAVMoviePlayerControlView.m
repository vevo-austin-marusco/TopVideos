//
//  TVAVMoviePlayerControlView.m
//  TopVideos
//
//  Created by New Admin User on 9/5/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "TVAVMoviePlayerControlView.h"
#import <MediaPlayer/MPVolumeView.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MPMoviePlayerController.h>

@interface TVAVMoviePlayerControlView (){
    
    UIView                  *airplayButtonPlaceHolderView;
    
    // UI for buffering video stream.
	UIView                  *bufferingIndicatorView;
	UIActivityIndicatorView *bufferingIndicator;
	UILabel                 *bufferingLabel;
	NSTimeInterval          bufferStartTime;
    
    BOOL iTunesLinkAvailable;
    BOOL isControlAdded;
    BOOL isPlayingOnAirPlay;
    
    // This is to keep track of how many times elapsedTimeChanged method gets called
	int elapsedTimeChangedCount;
    float scrubviewX;
}

@property (nonatomic, strong) UIView*               bottomControlBar;
@property (nonatomic, strong) UIButton*             volumeButton;
@property (nonatomic, strong) UILabel*              timeLabel;
@property (nonatomic, strong) UIButton*             playButton;
@property (nonatomic, strong) TVScrubView*          scrubView;
@property (nonatomic, strong) id                    mTimeObserver;


- (void)showAirPlayButtonIfAvailable;
- (void)elapsedTimeChanged;
- (void)stopFadeOut;
- (void)startFadeOut;
- (void)resizeScrubView;
- (BOOL)isPlayingOnTV;
- (void)updateBufferView;


@end

@implementation TVAVMoviePlayerControlView
@synthesize bottomControlBar, playButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.opaque = NO;
		self.clipsToBounds = YES;
		self.backgroundColor = [UIColor clearColor];
        
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		
		bufferingIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 80)];
		bufferingIndicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        bufferingIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
		bufferingIndicatorView.layer.cornerRadius = 6;
		bufferingIndicatorView.hidden = YES;
		bufferingIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		
		bufferingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bufferingIndicatorView.frame.size.width, 20)];
		bufferingLabel.center = CGPointMake(bufferingIndicatorView.frame.size.width / 2, bufferingIndicatorView.frame.size.height / 2 + 24);
		bufferingLabel.font = [UIFont boldSystemFontOfSize:12];
		bufferingLabel.textColor = [UIColor whiteColor];
		bufferingLabel.backgroundColor = [UIColor clearColor];
		bufferingLabel.textAlignment = NSTextAlignmentCenter;
		[bufferingIndicatorView addSubview:bufferingLabel];
		
		bufferingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		bufferingIndicator.center = CGPointMake(bufferingIndicatorView.frame.size.width / 2, bufferingIndicatorView.frame.size.height / 2 - 8);
		bufferingIndicator.frame = CGRectMake(ceil(self.frame.origin.x),
                                                        ceil(self.frame.origin.y),
                                                        ceil(self.frame.size.width),
                                                        ceil(self.frame.size.height));
		[bufferingIndicatorView addSubview:bufferingIndicator];
        [self addSubview:bufferingIndicatorView];
		
		bufferStartTime = 0.0f;
        
        
        //Bottom Control Bar
        self.bottomControlBar = [[UIView alloc] initWithFrame:CGRectZero];
        bottomControlBar.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        bottomControlBar.opaque = NO;
        bottomControlBar.autoresizingMask = UIViewAutoresizingFlexibleWidth ;//| UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:bottomControlBar];
        
        
        playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *playButtonImage = [UIImage imageNamed:@"player_pause_icon.png"];
        [playButton setImage:playButtonImage forState:UIControlStateNormal];
        [bottomControlBar addSubview:playButton];
        [playButton addTarget:self action:@selector(togglePlayPause:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *timeBackground = [UIImage imageNamed:@"playercontrol_time_bg.png"];
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(bottomControlBar.frame.size.width - timeBackground.size.width, 0, timeBackground.size.width, timeBackground.size.height)];
        _timeLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor clearColor];//[UIColor colorWithPatternImage:timeBackground];
        _timeLabel.opaque = NO;
        _timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [bottomControlBar addSubview:_timeLabel];
        
        self.scrubView = [[TVScrubView alloc] initWithFrame:CGRectZero];
        _scrubView.delegate = self;
        _scrubView.totalTime = self.player.duration;
        _scrubView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [bottomControlBar addSubview:_scrubView];
        
        self.tvConnectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvconnected.png"]];
        
        //get bundle for function
        static dispatch_once_t fetchBundleOnce;
        static NSBundle *bundle = nil;
        
        dispatch_once(&fetchBundleOnce, ^{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"VevoSDKResources"
                                                             ofType:@"bundle"];
            bundle = [NSBundle bundleWithPath:path];
        });
        
        // Add 2 text labels under the TV image.
        CGFloat h_lb1 = 35, h_lb2 = 30.;
        UILabel *tvLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tvConnectedImageView.frame.size.height-h_lb1-h_lb2-10, self.tvConnectedImageView.frame.size.width, h_lb1)];
        tvLabel1.backgroundColor = [UIColor clearColor];
        tvLabel1.textAlignment = NSTextAlignmentCenter; //UITextAlignmentCenter;
        //tvLabel1.text = VMLocalizedString(@"VM:tv_connected", nil);
        tvLabel1.textColor = [UIColor colorWithWhite:.6 alpha:1.];
        tvLabel1.font = [UIFont systemFontOfSize:22];
        [self.tvConnectedImageView addSubview:tvLabel1];
        
        NSString *result = nil;
        if (bundle) {
            result = [bundle localizedStringForKey:@"VM:tv_connected"
                                             value:nil
                                             table:nil];
        }
        
        tvLabel1.text = result;
        
        
        UILabel *tvLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tvConnectedImageView.frame.size.height-h_lb2-10, self.tvConnectedImageView.frame.size.width, h_lb2)];
        tvLabel2.backgroundColor = [UIColor clearColor];
        tvLabel2.textAlignment = NSTextAlignmentCenter;//UITextAlignmentCenter;
        //tvLabel2.text = VMLocalizedString(@"VM:play_on_tv", nil);
        tvLabel2.textColor = [UIColor colorWithWhite:.4 alpha:1.];
        tvLabel2.font = [UIFont systemFontOfSize:15];
        [self.tvConnectedImageView addSubview:tvLabel2];
        
        result = nil;
        if (bundle) {
            result = [bundle localizedStringForKey:@"VM:play_on_tv"
                                             value:nil
                                             table:nil];
        }
        
        tvLabel1.text = result;
        
        self.tvConnectedImageView.center = self.center;
        self.tvConnectedImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        //[self.tvConnectedImageView release];
        //[self toggleShowingOnTV:[self isPlayingOnTV]];
        
	}
    
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
    
    
	CGRect bottomControlBarFrame = self.bounds;
	bottomControlBarFrame.size.height = 40.0;
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    
    int bottomBarYOffset;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        bottomBarYOffset = 0;
    else
        bottomBarYOffset = UIInterfaceOrientationIsLandscape(orientation)? 0:0;
    
	bottomControlBarFrame.origin.y = self.bounds.size.height - bottomControlBarFrame.size.height - bottomBarYOffset;
    bottomControlBar.frame = bottomControlBarFrame;
    
	float x = 0;
	x = bottomControlBar.frame.size.width;
    if (![self isPlayingOnTV]) {
    	x = x - _volumeButton.frame.size.width;
    	_volumeButton.frame = CGRectMake(x, 0, _volumeButton.frame.size.width, _volumeButton.frame.size.height);
    }
	
	CGRect timeLabelFrame = _timeLabel.frame;
	self.timeLabel.frame = CGRectMake(x - timeLabelFrame.size.width, 0, timeLabelFrame.size.width, timeLabelFrame.size.height);
	
	x = 0;
	playButton.frame = CGRectMake(x, 0.0f, 50.0f, bottomControlBar.bounds.size.height);
	x += 50.0f;//playButtonImage.size.width;
	
	scrubviewX = x;
	float scrubViewWidth = _timeLabel.frame.origin.x - x + 50.0f;
    _scrubView.totalTime = self.player.duration;
	_scrubView.frame = CGRectMake(x, 0, scrubViewWidth, 40.0);
	_scrubView.userInteractionEnabled = YES;
    [bottomControlBar bringSubviewToFront:_scrubView];

	if (_player.controlStyle == VMMovieControlStyleEmbedded) {
        _scrubView.hidden = YES;
        _timeLabel.hidden = YES;
        _volumeButton.hidden = YES;
        self.bottomControlBar.backgroundColor = [UIColor clearColor];
    }else{
        _scrubView.hidden = NO;
        _timeLabel.hidden = NO;
        _volumeButton.hidden = NO;
        [self showAirPlayButtonIfAvailable];
    }
    
    self.tvConnectedImageView.center = self.center;
    
}

#pragma mark -
#pragma mark public Methods

/* Show the stop button in the movie player controller. */
-(void)showStopButton
{
    UIImage *playButtonImage = [UIImage imageNamed:@"player_pause_icon.png"];
    [playButton setImage:playButtonImage forState:UIControlStateNormal];
}

/* Show the play button in the movie player controller. */
-(void)showPlayButton
{
    UIImage *playButtonImage = [UIImage imageNamed:@"player_play_icon.png"];
    [playButton setImage:playButtonImage forState:UIControlStateNormal];
}

-(void)showBufferingIndicator{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    bufferingIndicatorView.hidden = NO;
    //bufferingLabel.text = VMLocalizedString(@"VM:spinner_buffering",nil);
   // bufferingLabel.text = [VMUtilities localizedStringForKey:msg withDefault:defaultMsg]
    //bufferingLabel.text = [self localizedStringForKey:@"VM:spinner_buffering" withDefault:nil inBundle:VMUtilities.vevoSDKBundle];
    // bufferingLabel.text = [self localizedStringForKey:@"VM:spinner_buffering" withDefault:nil inBundle:bundle];
    
    //get bundle for function
    static dispatch_once_t fetchBundleOnce;
    static NSBundle *bundle = nil;
    
    dispatch_once(&fetchBundleOnce, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VevoSDKResources"
                                                         ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:path];
    });
    
    NSString *result = nil;
    if (bundle) {
        result = [bundle localizedStringForKey:@"VM:spinner_buffering"
                                         value:nil
                                         table:nil];
    }
    
    bufferingLabel.text = result;
    
    [bufferingIndicator startAnimating];
}

-(void)hideBufferingIndicator{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    bufferingIndicatorView.hidden = YES;
    [bufferingIndicator stopAnimating];
}


-(void)enablePlayerButtons
{
    playButton.userInteractionEnabled = YES;
}

-(void)disablePlayerButtons
{
    playButton.userInteractionEnabled = NO;
}

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer
{
    double interval = .1f;
	
    
	double duration = [self.player duration];
	if (isfinite(duration))
	{
		interval = 1.0f; // duration / width;
	}
    
	/* Update the scrubber during normal playback. */
    self.mTimeObserver = [_player registerPlayerTimeObserverWithInterval:interval callbackBlock:^(CMTime time)
                          {
                              [self elapsedTimeChanged];
                          }];
}

#pragma mark -
#pragma mark private Methods
- (BOOL)isPlayingOnTV {
	//return [[VMTVOutManager defaultManager] tvoutStarted];
    return NO;
}

- (void)resizeScrubView {
    
    //VMDDLogVerbose(@"in");
	CGRect scrubViewFrame = _scrubView.frame;
	scrubViewFrame.origin.x = scrubviewX;
	scrubViewFrame.size.width = _timeLabel.frame.origin.x - _scrubView.frame.origin.x + 50.0f;
	_scrubView.frame = scrubViewFrame;
}


- (void)elapsedTimeChanged {
    
    // update analytics data (in particular Stream Sense) continuously throughout playback.
    if (self.player && [self.player currentVideo]) {
        //[[AnalyticsManager defaultManager] update:self.moviePlayer video:[self.delegate currentVideo] inPlaylist:[self.delegate playlist].title];
    }
    if (_player.controlStyle != VMMovieControlStyleEmbedded && _player.controlStyle != VMMovieControlStyleNone) {
        [self performSelectorOnMainThread:@selector(showAirPlayButtonIfAvailable) withObject:nil waitUntilDone:NO];
    }
    
	[_scrubView setCurrentTime:self.player.currentTime];
	int elapsedTime = (int)self.player.currentTime;
	if (elapsedTime > 0 && elapsedTime % 10 == 0) {
		//[_delegate recordDurationToBeaconing:elapsedTime];
	}
	
	BOOL isLiveStreaming = [[_player currentVideo] isLive]; //isnan(moviePlayer.duration);
	if (!isLiveStreaming && elapsedTimeChangedCount == 10) {
		//[[HistoryManager defaultManager] addToHistory:[delegate currentVideo]];
	}
	elapsedTimeChangedCount++;
	if (![self.player isAirPlayVideoActive]) {
		[_scrubView setBufferBar:bufferStartTime :self.player.playableDuration];
		[self updateBufferView];
	} else {
		[_scrubView setBufferBar:0 :0];
	}
}

- (void)showAirPlayButtonIfAvailable {
    
    if (!airplayButtonPlaceHolderView) {
        
        float x = bottomControlBar.frame.size.width - 40;
        
        CGRect rect = CGRectMake(x, 0, 40, bottomControlBar.frame.size.height);
        airplayButtonPlaceHolderView = [[UIView alloc] initWithFrame:rect];
        airplayButtonPlaceHolderView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        airplayButtonPlaceHolderView.hidden = YES;
        [bottomControlBar addSubview:airplayButtonPlaceHolderView];
        
        UIImageView *separatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VevoSDKResources.bundle/VMMoviePlayer/images/player_btn_separator.png"]];
        [airplayButtonPlaceHolderView addSubview:separatorImageView];
    }
    
    //TO-DO airplay showing icon
    /*
    if (![self isPlayingOnTV] && [VMAirPlayDetector defaultDetector].isAirPlayAvailable) {
        //VMDDLogInfo(@"isAirPlayAvailable");
        if (airplayButtonPlaceHolderView.hidden) {
            airplayButtonPlaceHolderView.hidden = NO;
            [_timeLabel vm_deltaX:-airplayButtonPlaceHolderView.frame.size.width];
            [_volumeButton vm_deltaX:-airplayButtonPlaceHolderView.frame.size.width];
            [self resizeScrubView];
        }else{
            if (airplayButtonPlaceHolderView.frame.origin.x < (_volumeButton.frame.origin.x + _volumeButton.frame.size.width)) {
                [_timeLabel vm_deltaX:-airplayButtonPlaceHolderView.frame.size.width];
                [_volumeButton vm_deltaX:-airplayButtonPlaceHolderView.frame.size.width];
                [self resizeScrubView];
            }
        }
        
    }
    
    
    else if (!airplayButtonPlaceHolderView.hidden) {
        VMDDLogInfo(@"isAirPlayAvailable 2");
        [_timeLabel vm_deltaX:airplayButtonPlaceHolderView.frame.size.width];
        [_volumeButton vm_deltaX:airplayButtonPlaceHolderView.frame.size.width];
        [self resizeScrubView];
        
        airplayButtonPlaceHolderView.hidden = YES;
        
        
    }
     */
}


- (void)updateBufferView {
}

/*
 Cancel the ongoing task such as waiting for fade out.
 */
- (void)cancelOngoingTasks
{
    [self stopFadeOut];
}

#pragma mark -
#pragma mark User Interaction
- (void)togglePlayPause:(id)sender {
	if ( [self.player isPlaying] ) {
		[self.player pausePlayer];
        [self showPlayButton];
	} else {
		[self.player startPlayer];
        [self showStopButton];
	}
}

- (void)airplayButtonPushed:(id)sender
{
   // [[VMSDKAnalyticsManager defaultManager] logWatchAirplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[touches anyObject] tapCount] == 1)
    {
        if (self.bottomControlBar.alpha != 0) {
                [self transitionOut];
        }
        else {
            [self transitionIn];
        }
        
        [_player onTouchPlayer];
    }
}

// reset fadeout timer if event detected in any other subviews
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
   // VMDDLogInfo(@"point =%@, bottomBar contains = %d", NSStringFromCGPoint(point), CGRectContainsPoint(self.bottomControlBar.frame, point));
	UIView *aView = [super hitTest:point withEvent:event];
	//VMDDLogVerbose(@"in");
    if (aView != self){
       // VMDDLogInfo(@"aView=%@ frame=%@", aView, NSStringFromCGRect(aView.frame));
		//[self startFadeOut];
        //[_player onTouchPlayer];
    }else{
       // VMDDLogInfo(@"hit controlView");
    }
	return aView;
}

#pragma mark ScrubViewDelegate methods

- (void)setNewPlaybackTime:(NSTimeInterval)newPlaybackTime {
	
    //VMDDLogVerbose(@"duration = %f,  seekTime=%f",_player.duration, newPlaybackTime);
    
    [_player seekToTime:newPlaybackTime ];
    
}

- (void)updateTimeLabel:(NSTimeInterval)currentTime {
    //VMDDLogInfo(@"duration=%f", _player.duration);
   // [[VMSDKAnalyticsManager defaultManager] update:self.player video:self.player.video inPlaylist:self.player.playlistTitle];
    
    int minutes = floor(((double)_player.duration / 60.0));
    int seconds = floor((double)_player.duration - (60 * minutes));
    
	_timeLabel.text = [NSString stringWithFormat:@"%@", /*[NSString formattedTimeFromInterval:currentTime], */[NSString stringWithFormat:@"%0.2d:%0.2d", minutes, seconds]];
    
}

- (void)pauseTimer {
	
    [self.player beginScrubbing];
    
    [self.player unregisterPlayerTimeObserver:_mTimeObserver];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self showBufferingIndicator];
    //
	[self stopFadeOut];
}

- (void)resumeTimer {
    
    [self hideBufferingIndicator];
    
    if (!_mTimeObserver) {
        [self initScrubberTimer];
    }
    [self.player endScrubbing];
    
	[self startFadeOut];
}


#pragma mark -
#pragma mark VMPlayerOverlayObject Methods

- (void)transitionOut{
    if (isPlayingOnAirPlay) return; // Don't fade out if airplay is on
	if ([self isPlayingOnTV]) return; // prevent fadeOut while playing on tv
	if (self.player.playerbackState != 0 && self.player.playerbackState != VMMoviePlaybackStatePlaying ) return; // Don't fade out if video is not playing
    
    [UIView animateWithDuration:.8 animations:^{
        self.bottomControlBar.alpha = 0.0;
    } completion:^(BOOL f0){
        self.isOnScreen = NO;
    }];
    
}
- (void)transitionIn
{
    //VMDDLogVerbose(@"in");
    [UIView animateWithDuration:.8 animations:^{
        
        self.bottomControlBar.alpha = 1.0;
        
    } completion:^(BOOL f0){
        self.isOnScreen = YES;
        [self startFadeOut];
    }];
    
}

- (BOOL)showOnTouch
{
    return YES;
}

-(BOOL) isShowing
{
    return self.isOnScreen;
}

- (VMOverlayType) overlayType
{
    return VMOverlayTypeVideo;
}

- (float)fadeOutSeconds
{
    if (_player.controlViewFadeoutDuration > 0.0) {
        return _player.controlViewFadeoutDuration;
    }
    return 7.0; //default
}


- (void)stopFadeOut {
    
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(transitionOut) object:nil];
    
}

- (void)startFadeOut {
	[self stopFadeOut];
	[self performSelector:@selector(transitionOut) withObject:nil afterDelay:[self fadeOutSeconds]];
    
}







@end

