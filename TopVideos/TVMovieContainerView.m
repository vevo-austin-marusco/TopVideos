//
//  TVMovieContainerViewController.m
//  TopVideos
//
//  Created by New Admin User on 9/4/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "TVMovieContainerView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <VevoSDK/VMConstants.h>
#import <VevoSDK/VMPlayerOverlayObject.h>
#import "TVPlayerTopBarView.h"
#import "TVVideoInfoOverlayView.h"

enum {
    kTagVideosTableCellImageView = 2000,
    kTagVideosTableCellTitleLabel,
    kTagVideosTableCellSubtitleLabel,
    kTagVideosTableCellSubtitleLabel2,
    kTagLeftHeaderTitle ,
    kTagPlaylistTable,
    kTagLeftHeader,
    kTagRightHeader,
    kTagCreditsView
};


@interface TVMovieContainerView ()
{
    int selectedIndex;

}

@property (nonatomic, strong) VMVideo *video;
@property (nonatomic, strong) UIView *portraitInfoView;
@property (nonatomic, strong) UIView *playerContainerView;
@property (nonatomic, strong) NSString *headerTitle;

@end

@implementation TVMovieContainerView

- (id)initWithFrame:(CGRect)frame DelegateObject:(NSObject *)inputDelegateObject
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegateObject = inputDelegateObject;
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor blackColor];
    
    [self setupPlayerContainerView];
    
    self.vodPlayer = [[VMMoviePlayerController alloc] initWithBaseView:self.playerContainerView];
    self.vodPlayer.controlStyle = VMMovieControlStyleFullscreen;
    self.vodPlayer.containerDelegate = self;
    //_vodPlayer.disableContinuousPlay = YES;
    
    [self.vodPlayer playVideo:self.video];
}

-(void)setupPlayerContainerView
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect playerFrame;
    
    if (UIInterfaceOrientationIsLandscape(orientation)){
        playerFrame = CGRectMake(0, 0, MAX(self.bounds.size.width, self.bounds.size.height), MIN(self.bounds.size.width, self.bounds.size.height));
    }else{
        playerFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    
    if (!self.playerContainerView) {
        self.playerContainerView = [[UIView alloc] initWithFrame:playerFrame];
        self.playerContainerView.multipleTouchEnabled = YES;
        self.playerContainerView.userInteractionEnabled = YES;
        [self addSubview:self.playerContainerView];
    }else
        self.playerContainerView.frame = playerFrame;
    
}

- (void)layoutSubviews
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect playerFrame;
    
    if (UIInterfaceOrientationIsLandscape(orientation)){
        playerFrame = CGRectMake(0, 0, MAX(self.bounds.size.width, self.bounds.size.height), MIN(self.bounds.size.width, self.bounds.size.height));
    }else{
        int moviePlayerVerticalHeight;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            moviePlayerVerticalHeight = self.frame.size.height;
        else
            moviePlayerVerticalHeight = self.frame.size.height;
        
        playerFrame = CGRectMake(0, 0, MIN(self.bounds.size.width, self.bounds.size.height), moviePlayerVerticalHeight);
    }
}



#pragma mark Top bar user action Methods
- (void)playVideo:(VMVideo *)sourceVideo
{
    self.video = sourceVideo;
    [self.vodPlayer playVideo:sourceVideo];
}
- (void)stopVideo
{
    [self.vodPlayer stopPlayer];
}

-(void) onCloseButtonTapped:(id)sender
{
    [self.vodPlayer stopPlayer];
    [self.delegateObject performSelector:@selector(removeVideoPlayer) withObject:nil];
}

- (void) moviePlayerDidStop
{
    //insert code to handle movie player stopping
}

#pragma mark VMMoviePlayerContainerDelegate Methods

- (void) movieplayerReadyToPlayVideo
{
    TVPlayerTopBarView *topBar = [[TVPlayerTopBarView alloc] initWithFrame:CGRectMake(0, 0, self.playerContainerView.bounds.size.width, 40)];
    topBar.video = self.video;
    [self.vodPlayer showOverlay:topBar];
}

- (void) moviePlayerEnterFullScreen
{
    // When the cell is touched, it should faint.
    [UIView animateWithDuration:.5 animations:^{
        self.playerContainerView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }completion:^(BOOL finished){
    }];
}

- (void) moviePlayerStartPlayingAds{
    //Freeze recommendation table when playing ads
    [self.delegateObject performSelector:@selector(startedPlayingAds) withObject:nil];
}
- (void) moviePlayerEndPlayingAds{
    //Re-enable recommendation table after playing ads
    [self.delegateObject performSelector:@selector(stoppedPlayingAds) withObject:nil];
}



@end
