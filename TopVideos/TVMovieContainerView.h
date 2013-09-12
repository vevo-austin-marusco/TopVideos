//
//  TVMovieContainerViewController.h
//  TopVideos
//
//  Created by New Admin User on 9/4/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VevoSDK/VMMoviePlayerController.h>

@interface TVMovieContainerView : UIView <VMMoviePlayerContainerDelegate>

@property(nonatomic, strong) VMMoviePlayerController *vodPlayer;
@property(nonatomic) int currentRanking;
@property(nonatomic, weak) NSObject *delegateObject;
@property (nonatomic, strong) UIView *playerContainerView;

- (void)playVideo:(VMVideo *)sourceVideo;
- (void)stopVideo;
- (void)onCloseButtonTapped:(id)sender;
- (void)moviePlayerDidStop;
- (void)onAddButtonTapped:(id)sender;
- (void)onShareButtonTapped:(id)sender;
- (void)onBuyButtonTapped:(id)sender;
- (void)onInfoButtonTapped:(id)sender;


- (id)initWithFrame:(CGRect)frame DelegateObject:(NSObject *)inputDelegateObject;

@end
