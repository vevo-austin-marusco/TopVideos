//
//  TVViewController.h
//  TopVideos
//
//  Created by Austin Marusco on 9/3/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VevoSDK/VMMoviePlayerController.h>

@interface TVMainViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIScrollViewDelegate,VMMoviePlayerContainerDelegate>

- (void)removeVideoPlayer;
- (void)startedPlayingAds;
- (void)stoppedPlayingAds;
- (void)moviePlayerStartPlayRecommendationAt:(int)index;
- (void)moviePlayerEnterFullScreen;
- (void)playVideo:(VMVideo *)sourceVideo;
- (void)stopVideo;
- (void)onCloseButtonTapped:(id)sender;
- (void)moviePlayerDidStop;
- (void)onAddButtonTapped:(id)sender;
- (void)onShareButtonTapped:(id)sender;
- (void)onBuyButtonTapped:(id)sender;
- (void)onInfoButtonTapped:(id)sender;

@end
