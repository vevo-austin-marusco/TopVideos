//
//  VMPlayerOverlayObject.h
//  vevo-ios-sdk
//
//  Created by Harry Xu on 5/9/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    VMOverlayTypePlayer = 0,
    VMOverlayTypeVideo  = 1,
    VMOverlayTypeButtonAction  = 2
	
} VMOverlayType;

@protocol VMPlayerOverlayObject <NSObject>

- (void)transitionIn;
- (void)transitionOut;
- (float)fadeOutSeconds;
- (VMOverlayType) overlayType;

- (BOOL)showOnTouch;
- (BOOL)isShowing;


@end
