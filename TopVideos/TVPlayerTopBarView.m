//
//  PlayerTopBarView.m
//  ExampleUseVevoSDK
//
//  Created by Harry Xu on 7/15/13.
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
        
        self.backgroundColor = [UIColor clearColor];
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
        [self.closeButton setBackgroundColor:[UIColor redColor]];
        self.closeButton = [self buttonWith1PixelImage:nil
                                                        title:@""
                                              foregroundImage:[UIImage imageNamed:@"close_button"]
                                                         font:headerFont
                                                    textColor:headerFontColor
                                                 cornerRadius:5
                                                     maxWidth:80 minWidth:minWidth maxHeight:40 imageTextSpace:0];
        [_closeButton addTarget:self.container action:@selector(onCloseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_closeButton];
        
      /*  self.shareButton = [self buttonWith1PixelImage:nil
                                                        title:@"Share"
                                              foregroundImage:[UIImage imageNamed:@"VevoSDKResources.bundle/VMMoviePlayer/images/player_share_icon_pad.png"]
                                                         font:headerFont
                                                    textColor:headerFontColor
                                                 cornerRadius:5
                                                     maxWidth:120 minWidth:minWidth maxHeight:40 imageTextSpace:10];
        _shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_shareButton addTarget:self.container action:@selector(onShareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shareButton];
        
        
        
        self.infoButton = [self buttonWith1PixelImage:nil
                                                       title:@"Info"
                                             foregroundImage:[UIImage imageNamed:@"VevoSDKResources.bundle/VMMoviePlayer/images/player_info_icon_pad.png"]
                                                        font:headerFont
                                                   textColor:headerFontColor
                                                cornerRadius:5
                                                    maxWidth:120 minWidth:minWidth maxHeight:40 imageTextSpace:10];
        _infoButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [_infoButton addTarget:self.container action:@selector(onInfoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _infoButton.hidden = YES;
        [self addSubview:_infoButton];
        
        self.buyButton = [self buttonWith1PixelImage:nil
                                                      title:@"Buy"
                                            foregroundImage:[UIImage imageNamed:@"VevoSDKResources.bundle/VMMoviePlayer/images/player_buy_icon_pad.png"]
                                                       font:headerFont
                                                  textColor:headerFontColor
                                               cornerRadius:5
                                                   maxWidth:120 minWidth:minWidth maxHeight:40 imageTextSpace:10];
        _buyButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_buyButton addTarget:self.container action:@selector(onBuyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _buyButton.hidden = YES;
        [self addSubview:_buyButton];
       */
        
    }
    return self;
}


- (void)layoutSubviews
{
    CGFloat buttonWidth = 120.0f;
    CGFloat buttonHeight = 0.0f;
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
    
    
    int xPosition = _closeButton.frame.origin.x;
    
    buttonHeight = _shareButton.bounds.size.height;
    _shareButton.frame = CGRectMake(xPosition - buttonWidth - xShift, yOffset, buttonWidth, buttonHeight);
    NSLog(@"shareButton frame=%@", NSStringFromCGRect(_shareButton.frame));
    xPosition = _shareButton.frame.origin.x;
    
    _buyButton.hidden = NO;
    buttonHeight = _buyButton.bounds.size.height;
    _buyButton.frame = CGRectMake(xPosition - buttonWidth - xShift, yOffset, buttonWidth, buttonHeight);
    NSLog(@"buyButton frame=%@", NSStringFromCGRect(_buyButton.frame));
    
    _infoButton.hidden = NO;
    buttonHeight = _infoButton.bounds.size.height;
    _infoButton.frame = CGRectMake(0, yOffset, buttonWidth, buttonHeight);
    xPosition = _infoButton.frame.origin.x;
    
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

#pragma mark -
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
