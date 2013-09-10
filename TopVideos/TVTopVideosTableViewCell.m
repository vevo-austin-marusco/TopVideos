//
//  VMTopVideosTableViewCell.m
//  TopVideos
//
//  Created by New Admin User on 9/3/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "TVTopVideosTableViewCell.h"


//view constants
float const kTextContainerBufferRatio = 0.025;
float const kTextContainerRatioHeight = 0.25;
float const kArtistNameLabelRatioHeight = 0.3;
float const kTopVideoCountRatioHeight = 0.15;
float const kTopVideoCountRatioWidth = 0.2;
float const kTopVideoCountBufferWidthRatio = 0.07;
float const kTopVideoCountBufferHeightRatio = 0.01;

//color constants
float const kArtistNameColorR = 51/255.0f;
float const kArtistNameColorG = 51/255.0f;
float const kArtistNameColorB = 71/255.0f;
float const kTitleNameColorR = 249/255.0f;
float const kTitleNameColorG = 0/255.0f;
float const kTitleNameColorB = 148/255.0f;
//ARTIST_NAME_COLOR @"333347"
//TITLE_NAME_COLOR @"f90094"

@implementation TVTopVideosTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

-(void)setup{
    self.artistImageView = [[UIImageView alloc] init];
    self.topVideoCountLabel = [[UILabel alloc] init];
    self.artistNameLabel = [[UILabel alloc] init];
    self.songTitleLabel = [[UILabel alloc] init];
    self.textContainerView = [[UIView  alloc] init];
    
    self.songTitleLabel.backgroundColor = [UIColor clearColor];
    self.textContainerView.backgroundColor = [UIColor clearColor];
    self.artistNameLabel.backgroundColor = [UIColor clearColor];
    self.topVideoCountLabel.backgroundColor = [UIColor clearColor];
    
    self.topVideoCountLabel.textColor = [UIColor whiteColor];
    self.artistNameLabel.textColor = [UIColor colorWithRed:kArtistNameColorR green:kArtistNameColorG blue:kArtistNameColorB alpha:1.0];
    self.songTitleLabel.textColor = [UIColor colorWithRed:kTitleNameColorR green:kTitleNameColorG blue:kTitleNameColorB alpha:1.0];
    
    [self.songTitleLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Black" size:22]];
    [self.artistNameLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Black" size:17]];
    [self.topVideoCountLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Black" size:50]];
    
    self.artistImageView.contentMode = UIViewContentModeScaleAspectFill | UIViewContentModeScaleAspectFill;
    
    self.topVideoCountLabel.adjustsFontSizeToFitWidth = YES;
    self.artistNameLabel.adjustsFontSizeToFitWidth = YES;
    self.songTitleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.textContainerView.clipsToBounds = YES;
    self.artistImageView.clipsToBounds = YES;

    [self.textContainerView addSubview:self.artistNameLabel];
    [self.textContainerView addSubview:self.songTitleLabel];
    [self addSubview:self.artistImageView];
    [self addSubview:self.topVideoCountLabel];
    [self addSubview:self.textContainerView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews{
    
    self.artistImageView.frame = CGRectMake(0,
                                            0,
                                            self.frame.size.width,
                                            self.frame.size.height * (1 - kTextContainerRatioHeight));
    self.textContainerView.frame = CGRectMake(self.frame.size.height * kTextContainerBufferRatio,
                                              (self.frame.size.height * (1 - kTextContainerRatioHeight)) + (self.frame.size.height * kTextContainerBufferRatio),
                                              self.frame.size.width - (2 * (self.frame.size.height * kTextContainerBufferRatio)),
                                              self.frame.size.height * kTextContainerRatioHeight - (2 * (self.frame.size.height * kTextContainerBufferRatio)));
    self.artistNameLabel.frame = CGRectMake(0,
                                            0,
                                            self.textContainerView.frame.size.width,
                                            self.textContainerView.frame.size.height * kArtistNameLabelRatioHeight);
    self.songTitleLabel.frame = CGRectMake(0,
                                           self.textContainerView.frame.size.height * kArtistNameLabelRatioHeight,
                                           self.textContainerView.frame.size.width,
                                           self.textContainerView.frame.size.height * (1 - kArtistNameLabelRatioHeight) - (2.5 * (self.frame.size.height * kTextContainerBufferRatio)));
    self.topVideoCountLabel.frame = CGRectMake((self.frame.size.width * kTopVideoCountBufferWidthRatio),
                                               (self.frame.size.height * (1 - kTextContainerRatioHeight)) - (self.frame.size.height * kTopVideoCountRatioHeight) + (self.frame.size.height * kTopVideoCountBufferHeightRatio),
                                               self.frame.size.width * kTopVideoCountRatioWidth,
                                               self.frame.size.height * kTopVideoCountRatioHeight);
    
    
}

@end
