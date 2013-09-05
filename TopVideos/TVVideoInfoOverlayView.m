//
//  VMVideoInfoOverlayView.m
//  TopVideos
//
//  Created by New Admin User on 9/4/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "TVVideoInfoOverlayView.h"

enum {
    
    kTagTitleLabel = 100,
    kTagArtistLabel,
    kTagExplicitLabel,
    kTagSeparator,
    kTagScrollView,
    kTagFacebookButton
};

@interface TVVideoInfoOverlayView ()
{
    
}
@property (nonatomic, readwrite) BOOL transitioning;

@end


@implementation TVVideoInfoOverlayView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.transitioning = NO;
        
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:.7];
        // Initialization code
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
        
        self.artistLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _artistLabel.numberOfLines = 0;
        _artistLabel.font = [UIFont systemFontOfSize:16];
        _artistLabel.textColor = [UIColor grayColor];
        _artistLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_artistLabel];
        
    }
    return self;
}


- (void)layoutSubviews
{
    CGFloat xEdge = 10, xOffset = xEdge;
    CGFloat width = self.frame.size.width - 2*xEdge;
    
    CGFloat yEdge = 20., yOffset = yEdge, yGap = 2;
    
    CGSize titleSize = [[_video title] sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
    _titleLabel.frame = CGRectMake(xOffset, yOffset, width, titleSize.height);
    _titleLabel.text = [_video title];
    
    yOffset += titleSize.height + yGap;
    
    CGSize artistSize = [[_video artist] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
    _artistLabel.frame = CGRectMake(xOffset, yOffset, width, artistSize.height);
    _artistLabel.text = [_video artist];
    
    yOffset += artistSize.height + yEdge;
    
    
    
    // Scroll view with credits info
    
    UIScrollView *scrollView = (UIScrollView *)[self viewWithTag:kTagScrollView];
    if (!scrollView)
    {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, yOffset, self.frame.size.width, self.frame.size.height-yOffset-yEdge)];
        scrollView.tag = kTagScrollView;
        
        
        UIFont *ft0 = [UIFont systemFontOfSize:15];
        UIFont *ft1 = [UIFont boldSystemFontOfSize:15];
        
        for (NSDictionary *credit in _video.credits)
        {
            if ([credit valueForKey:@"Key"] == [NSNull null] ||
                [credit valueForKey:@"Value"] == [NSNull null] ||
                [[credit valueForKey:@"Key"] isEqualToString:@""] ||
                [[credit valueForKey:@"Value"] isEqualToString:@""]) {
                continue;
            }
            
            
            
            NSString *title = [[credit valueForKey:@"Key"] uppercaseString];
            
            CGSize cz = [NSLocalizedString(title, nil) sizeWithFont:ft0 constrainedToSize:CGSizeMake(self.frame.size.width-2*xEdge, 100)];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xEdge, yOffset-scrollView.frame.origin.y, cz.width, cz.height)];
            titleLabel.textAlignment = NSTextAlignmentRight;
            titleLabel.text = NSLocalizedString(title, nil);
            titleLabel.font = ft0;
            titleLabel.numberOfLines = 0;
            //titleLabel.textColor = [@"#7b7b7b" colorFromHex];
            titleLabel.textColor = [UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1];
            titleLabel.backgroundColor = [UIColor clearColor];
            [scrollView addSubview:titleLabel];
            
            
            yOffset += cz.height;
            
            NSString *description = [credit valueForKey:@"Value"];
            cz = [description sizeWithFont:ft1 constrainedToSize:CGSizeMake(self.frame.size.width-2*xEdge, 100)];
            UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset-scrollView.frame.origin.y, cz.width, cz.height)];
            descriptionLabel.text = description;
            descriptionLabel.numberOfLines = 0;
            descriptionLabel.font = ft1;
            descriptionLabel.textColor = [UIColor whiteColor];
            descriptionLabel.backgroundColor = [UIColor clearColor];
            [scrollView addSubview:descriptionLabel];
            
            
            yOffset += cz.height + yEdge;
        }
        
        [self addSubview:scrollView];
        
    }
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, yOffset - scrollView.frame.origin.y);
    
    
    
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (void)transitionOut{
    
    if (!self.transitioning) {
        self.transitioning = YES;
    
    [UIView animateWithDuration:.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.frame = CGRectMake(-280, 0, 280, 460);
        
    } completion:^(BOOL f0){
        self.transitioning = NO;
        self.isOnScreen = NO;
    }];
        
    }
    
}
- (void)transitionIn
{
    if (!self.transitioning) {
            self.transitioning = YES;
        
        [UIView animateWithDuration:.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(0, 0, 280, 460);
        } completion:^(BOOL f0){
            self.transitioning = NO;
            self.isOnScreen = YES;
            [self performSelector:@selector(transitionOut) withObject:nil afterDelay:[self fadeOutSeconds]];
        }];
        
    }
    
}

- (BOOL)showOnTouch
{
    return NO;
}

-(BOOL) isShowing
{
    return self.isOnScreen;
}


- (float)fadeOutSeconds
{
    return  7.0;
}

- (VMOverlayType) overlayType
{
    return VMOverlayTypeButtonAction;
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

