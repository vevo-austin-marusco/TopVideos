//
//  VMEntityBase.h
//  vevo-ios-sdk
//
//  Created by Harry Xu on 4/9/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMEntityBase : NSObject {
	NSMutableDictionary *properties;
}

@property (nonatomic, strong) NSMutableDictionary *properties;
@property (nonatomic, strong) NSString *imageUrl;


@property (nonatomic, strong) NSString *originalImageUrl;


- (id)initFromDictionary:(NSDictionary *)dictionary;

- (NSString*)imageUrlWithSize:(int)width height:(int)height;

- (NSString*)imageUrlWithSize:(NSString*)url width:(int)width;
- (NSString*)imageUrlWithSize:(NSString*)url width:(int)width height:(int)height;

- (NSString*)thumbURL;
- (NSString*)smallerThumbURL;
- (NSString*)chartImageURL;




@end