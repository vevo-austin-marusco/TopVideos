//
//  TVPlayerTopBarView.m
//  TopVideos
//
//  Created by New Admin User on 9/4/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "TVPlayerTopBarView.h"
#import <QuartzCore/QuartzCore.h>
#import "TVMovieContainerView.h"

@interface TVPlayerTopBarView ()
{
    
}
@property (nonatomic, weak) TVMovieContainerView  *container;
@property (nonatomic, readwrite) BOOL isOnScreen;

@end

@implementation TVPlayerTopBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:.5f];
        self.opaque = YES;
        self.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        
        UIFont *headerFont;
        int minWidth;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            headerFont = [UIFont fontWithName:@"ProximaNovaA-Regular" size:14.0f];
            minWidth = 120;
        }else{
            headerFont = [UIFont fontWithName:@"ProximaNovaA-Semibold" size:10.0f];
            minWidth = 70;
        }
        
        UIColor *headerFontColor = [UIColor lightGrayColor];
        
        self.closeButton = [self buttonWith1PixelImage:nil
                                                 title:@"Done"
                                       foregroundImage:[UIImage imageNamed:@"VevoSDKResources.bundle/VMMoviePlayer/images/player_done_icon_pad.png"]
                                                  font:headerFont
                                             textColor:headerFontColor
                                          cornerRadius:5
                                              maxWidth:100 minWidth:minWidth maxHeight:40 imageTextSpace:10];
        [self.closeButton addTarget:self.container action:@selector(onCloseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.closeButton.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_closeButton];
        
    }
    return self;
}


- (void)layoutSubviews
{
    CGFloat buttonWidth = 120.0f;
    CGFloat yOffset = 0.0f;
    CGFloat xShift = 20.0f;
    
    UIFont *headerFont;
    int minWidth;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        headerFont = [UIFont fontWithName:@"ProximaNovaA-Regular" size:14.0f];
        minWidth = 120;
    }else{
        headerFont = [UIFont fontWithName:@"ProximaNovaA-Semibold" size:10.0f];
        buttonWidth = 70.0f;
        xShift = 8.0f;
        minWidth = 70;
    }
    
    _closeButton.frame = CGRectMake(self.frame.size.width-_closeButton.bounds.size.width/*85.0f*/, yOffset, _closeButton.bounds.size.width, _closeButton.bounds.size.height);
}

#pragma mark -
#pragma mark VMPlayerOverlayObject Methods

- (void)transitionOut{
    
    [UIView animateWithDuration:.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.alpha = 0.0;
        
    } completion:^(BOOL f0){
        self.isOnScreen = NO;
        
    }];
    
}
- (void)transitionIn
{
	
    [UIView animateWithDuration:.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL f0){
        self.isOnScreen = YES;
        [self performSelector:@selector(transitionOut) withObject:nil afterDelay:[self fadeOutSeconds]];
    }];
    
    
}

- (BOOL)showOnTouch
{
    return YES;
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
    return VMOverlayTypeVideo;
}

#pragma mark Helper Methods
- (UIButton *)buttonWith1PixelImage:(UIImage *)pixelImage title:(NSString *)title foregroundImage:(UIImage *)foregroundImage font:(UIFont *)font textColor:(UIColor *)textColor cornerRadius:(CGFloat)cornerRadius maxWidth:(CGFloat)maxWidth minWidth:(CGFloat)minWidth maxHeight:(CGFloat)maxHeight imageTextSpace:(CGFloat)space
{
    UIImage *buttonImgNormal = nil;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
        buttonImgNormal = [pixelImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    else {
        buttonImgNormal = [pixelImage stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize cz = [title sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, maxHeight)];
    [button setImage:foregroundImage forState:UIControlStateNormal];
    [button setTitle:[NSString stringWithFormat:@" %@", title] forState:UIControlStateNormal];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    button.titleLabel.font = font;
    CGFloat buttonContentInsetLeft = space;
    CGFloat contentLength = cz.width + foregroundImage.size.width + buttonContentInsetLeft;
    CGFloat buttonWidth = minWidth;
    if (contentLength + buttonContentInsetLeft*2 > minWidth)
        buttonWidth = contentLength + buttonContentInsetLeft*2;
    
    button.frame = CGRectMake(0, 0, buttonWidth, maxHeight);
    [button setBackgroundImage:buttonImgNormal forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = cornerRadius;
    
    return button;
}


@end
