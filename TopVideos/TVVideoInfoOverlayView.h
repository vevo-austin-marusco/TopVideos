//
//  VMVideoInfoOverlayView.h
//  TopVideos
//
//  Created by New Admin User on 9/4/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VevoSDK/VMPlayerOverlayObject.h>
#import <VevoSDK/VMVideo.h>

@interface TVVideoInfoOverlayView : UIView<VMPlayerOverlayObject>

@property (nonatomic, weak) VMVideo *video;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UILabel *artistLabel;
@property (nonatomic, readwrite) BOOL isOnScreen;

@end
