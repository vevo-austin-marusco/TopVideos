//
//  VMPlaylist.h
//  vevo-ios-sdk
//
//  Created by Harry Xu on 4/15/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "VMEntityBase.h"
#import "VMVideo.h"

typedef enum {
	kPlaylistTypeRemote,
	kPlaylistTypeLocal,
    kPlaylistTypeCustomLocal,
    kPlaylistTypeCustomRemote
} PlaylistType;

@interface VMPlaylist : VMEntityBase
{
	NSURL           *shortURL;
    
    BOOL            isPendingSync;
    BOOL            isPendingCreate;
    
    NSString        *playlistId;
    NSString        *title;
	NSString        *playlistDescription;
    NSString        *username;
    
    int             videoCount;
    
    PlaylistType    playlistType;
}

@property (nonatomic, assign) BOOL              isPendingSync;
@property (nonatomic, assign) BOOL              isPendingCreate;

@property (nonatomic, strong) NSString          *playlistId;
@property (nonatomic, strong) NSString          *title;
@property (nonatomic, strong) NSString          *playlistDescription;
@property (nonatomic, strong) NSString          *username;
@property (nonatomic, strong) NSURL*            webURL;
@property (nonatomic) int                       videoCount;
@property (nonatomic) PlaylistType              playlistType;

@property (nonatomic, strong) NSMutableArray    *videos;
@property (nonatomic, strong) NSMutableArray    *shuffledVideos;

+ (VMPlaylist*)newPlaylist;
+ (VMPlaylist*)newPlaylistWithTitle:(NSString*)aTitle;
+ (VMPlaylist*)playlistWithTitle:(NSString*)title description:(NSString*)description;

- (id)initFromDictionary:(NSDictionary *)dictionary type:(PlaylistType)type;

/**
 Call this method to load video data to the properties from a dictionary
 */
- (void)loadData:(NSDictionary *)data;

- (NSString*)vectorizedIsrcs;

- (void)addVideo:(VMVideo*)aVideo;

- (void)removeVideoAtIndex:(int)index;

- (NSURL*)shortURL;

// iPhone only methods
- (NSDictionary*)toDictionary;
- (void)createShuffledVideoOrder;
- (void)removeShuffledVideoOrder;
- (VMVideo*)getVideoAtPosition:(int)position;

@end
