//
//  VMApiFacade.h
//  VEVO
//
//  Created by Harry Xu on 3/12/13.
//  Copyright (c) 2013 VEVO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Void_Id)(id);

@interface VMApiFacade : NSObject

// *
// * used to get shared object--singleton //
// *
+(VMApiFacade*) sharedInstance;

/**
 Asynchronous call to fetch a Carousel information from the server.
 @param successBlock    successBlock  with result.
 @param errorBlock      errorBlock.
 */
//- (void)getCarouselWithSuccessBlock:(Void_Id)successBlock errorBlock:(Void_Id)errorBlock;

//Search
- (void)searchArtistWithTerm:(NSString *)term offset:(int)offset limit:(int)limit successBlock:(Void_Id)successBlock errorBlock:(Void_Id)errorBlock;

- (void)searchVideoWithTerm:(NSString *)term offset:(int)offset limit:(int)limit successBlock:(Void_Id)successBlock errorBlock:(Void_Id)errorBlock;

- (void)searchLookAheadWithTerm:(NSString *)term successBlock:(Void_Id)successBlock errorBlock:(Void_Id)errorBlock;

- (void)getTopVideosForOrder:(NSString *)orderString genre:(NSString *)genre offset:(int)offset limit:(int)limit successBlock:(Void_Id)successBlock errorBlock:(Void_Id)errorBlock;

- (void)searchWithIsrc:(NSString *)isrc successBlock:(Void_Id)successBlock errorBlock:(Void_Id)errorBlock;

//Movie Player
- (void)getAllRecommendationsForIsrc:(NSString *)isrc successBlock:(Void_Id)successBlock errorBlock:(Void_Id)errorBlock;

- (void)getExtendedVideoForIsrc:(NSString *)isrc successBlock:(Void_Id)successBlock errorBlock:(Void_Id)errorBlock;

- (void)getVideoRenditionsForIsrc:(NSString *)isrc successBlock:(Void_Id)successBlock errorBlock:(Void_Id)errorBlock;

- (void)getVideoForShowId:(int)showId episode:(NSString *)episodeId successBlock:(Void_Id)successBlock errorBlock:(Void_Id)errorBlock;

@end
