//
//  TVPlayerTopBarView.h
//  TopVideos
//
//  Created by Austin Marusco.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VevoSDK/VMPlayerOverlayObject.h>
#import <VevoSDK/VMVideo.h>

@interface TVPlayerTopBarView : UIView<VMPlayerOverlayObject>

@property (nonatomic, weak) VMVideo *video;

@property (nonatomic, strong) UIButton* closeButton;
@property (nonatomic, strong) UIButton* infoButton;
@property (nonatomic, strong) UIButton* buyButton;
@property (nonatomic, strong) UIButton* addButton;
@property (nonatomic, strong) UIButton* shareButton;


@end
