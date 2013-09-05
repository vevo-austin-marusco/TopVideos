//
//  VMTopVideosTableViewCell.h
//  TopVideos
//
//  Created by New Admin User on 9/3/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVTopVideosTableViewCell : UITableViewCell

@property (nonatomic,retain) UIImageView *artistImageView;
@property (nonatomic,retain) UILabel *topVideoCountLabel;
@property (nonatomic,retain) UILabel *artistNameLabel;
@property (nonatomic,retain) UILabel *songTitleLabel;
@property (nonatomic,retain) UIView *textContainerView;

@end
