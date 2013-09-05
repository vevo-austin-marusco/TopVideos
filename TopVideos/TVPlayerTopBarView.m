//
//  TVPlayerTopBarView.m
//  TopVideos
//
//  Created by New Admin User on 9/4/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "TVPlayerTopBarView.h"
#import <QuartzCore/QuartzCore.h>


#define DONE_BUTTON_RATIO_HEIGHT 0.75
#define DONE_BUTTON_BUFFER_RATIO_WIDTH 0.1

@interface TVPlayerTopBarView ()
{
    
}

@property (nonatomic, readwrite) BOOL isOnScreen;
@property (nonatomic, readwrite) BOOL transitioning;
@property (nonatomic, weak) TVMovieContainerView  *container;

@end

@implementation TVPlayerTopBarView

- (id)initWithFrame:(CGRect)frame Container:(TVMovieContainerView *)newContainer
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.userInteractionEnabled = YES;
        self.container = newContainer;
        
        self.transitioning = NO;
        
        self.closeButton = [[UIButton alloc] init];
        self.closeButton.backgroundColor = [UIColor clearColor];
        [self.closeButton setImage:[UIImage imageNamed:@"close_button"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self.container action:@selector(onCloseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.closeButton.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_closeButton];
        
    }
    return self;
}


- (void)layoutSubviews
{
    self.closeButton.frame = CGRectMake(self.frame.size.width - self.frame.size.height * DONE_BUTTON_RATIO_HEIGHT - (self.frame.size.height - self.frame.size.height * DONE_BUTTON_RATIO_HEIGHT)/2,
                                        (self.frame.size.height - self.frame.size.height * DONE_BUTTON_RATIO_HEIGHT)/2,
                                        self.frame.size.height * DONE_BUTTON_RATIO_HEIGHT,
                                        self.frame.size.height * DONE_BUTTON_RATIO_HEIGHT);
}

#pragma mark -
#pragma mark VMPlayerOverlayObject Methods

- (void)transitionOut{
    
    if (!self.transitioning) {
        
        self.transitioning = YES;
        
        [UIView animateWithDuration:.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.alpha = 0.0;
            
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
            self.alpha = 1.0;
        } completion:^(BOOL f0){
            self.transitioning = NO;
            self.isOnScreen = YES;
            [self performSelector:@selector(transitionOut) withObject:nil afterDelay:[self fadeOutSeconds]];
        }];
    }
    
    
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


@end
