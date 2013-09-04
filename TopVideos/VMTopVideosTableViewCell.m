//
//  VMTopVideosTableViewCell.m
//  TopVideos
//
//  Created by New Admin User on 9/3/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "VMTopVideosTableViewCell.h"

@implementation VMTopVideosTableViewCell

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
    
    self.songTitleLabel.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.artistImageView];
    [self addSubview:self.topVideoCountLabel];
    [self addSubview:self.artistNameLabel];
    [self addSubview:self.songTitleLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews{
    self.artistImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.artistImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.songTitleLabel.frame = CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height);
    
}

@end
