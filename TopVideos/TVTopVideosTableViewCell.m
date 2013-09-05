//
//  VMTopVideosTableViewCell.m
//  TopVideos
//
//  Created by New Admin User on 9/3/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "TVTopVideosTableViewCell.h"

#define TEXT_CONTAINER_BUFFER_RATIO 0.025
#define TEXT_CONTAINER_RATIO_HEIGHT 0.25
#define ARTIST_NAME_LABEL_RATIO_HEIGHT 0.3
#define TOP_VIDEO_COUNT_RATIO_HEIGHT 0.15
#define TOP_VIDEO_COUNT_RATIO_WIDTH 0.2
#define TOP_VIDEO_COUNT_BUFFER_WIDTH_RATIO 0.07
#define TOP_VIDEO_COUNT_BUFFER_HEIGHT_RATIO 0.01

//ARTIST_NAME_COLOR @"333347"
//TITLE_NAME_COLOR @"f90094"
#define ARTIST_NAME_COLOR_R 51/255.0f
#define ARTIST_NAME_COLOR_G 51/255.0f
#define ARTIST_NAME_COLOR_B 71/255.0f
#define TITLE_NAME_COLOR_R 249/255.0f
#define TITLE_NAME_COLOR_G 0/255.0f
#define TITLE_NAME_COLOR_B 148/255.0f

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
    self.artistNameLabel.textColor = [UIColor colorWithRed:ARTIST_NAME_COLOR_R green:ARTIST_NAME_COLOR_G blue:ARTIST_NAME_COLOR_B alpha:1.0];
    self.songTitleLabel.textColor = [UIColor colorWithRed:TITLE_NAME_COLOR_R green:TITLE_NAME_COLOR_G blue:TITLE_NAME_COLOR_B alpha:1.0];
    
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
                                            self.frame.size.height * (1 - TEXT_CONTAINER_RATIO_HEIGHT));
    self.textContainerView.frame = CGRectMake(self.frame.size.height * TEXT_CONTAINER_BUFFER_RATIO,
                                              (self.frame.size.height * (1 - TEXT_CONTAINER_RATIO_HEIGHT)) + (self.frame.size.height * TEXT_CONTAINER_BUFFER_RATIO),
                                              self.frame.size.width - (2 * (self.frame.size.height * TEXT_CONTAINER_BUFFER_RATIO)),
                                              self.frame.size.height * TEXT_CONTAINER_RATIO_HEIGHT - (2 * (self.frame.size.height * TEXT_CONTAINER_BUFFER_RATIO)));
    self.artistNameLabel.frame = CGRectMake(0,
                                            0,
                                            self.textContainerView.frame.size.width,
                                            self.textContainerView.frame.size.height * ARTIST_NAME_LABEL_RATIO_HEIGHT);
    self.songTitleLabel.frame = CGRectMake(0,
                                           self.textContainerView.frame.size.height * ARTIST_NAME_LABEL_RATIO_HEIGHT,
                                           self.textContainerView.frame.size.width,
                                           self.textContainerView.frame.size.height * (1 - ARTIST_NAME_LABEL_RATIO_HEIGHT) - (2.5 * (self.frame.size.height * TEXT_CONTAINER_BUFFER_RATIO)));
    self.topVideoCountLabel.frame = CGRectMake((self.frame.size.width * TOP_VIDEO_COUNT_BUFFER_WIDTH_RATIO),
                                               (self.frame.size.height * (1 - TEXT_CONTAINER_RATIO_HEIGHT)) - (self.frame.size.height * TOP_VIDEO_COUNT_RATIO_HEIGHT) + (self.frame.size.height * TOP_VIDEO_COUNT_BUFFER_HEIGHT_RATIO),
                                               self.frame.size.width * TOP_VIDEO_COUNT_RATIO_WIDTH,
                                               self.frame.size.height * TOP_VIDEO_COUNT_RATIO_HEIGHT);
    
    
}

@end
