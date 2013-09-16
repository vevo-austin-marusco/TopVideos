//
//  TVAppDelegate.m
//  TopVideos
//
//  Created by Austin Marusco on 9/3/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "TVAppDelegate.h"
#import <VevoSDK/VevoSDK.h>


@implementation TVAppDelegate

@synthesize genres = _genres;
@synthesize genreData = _genreData;
@synthesize genreDetails = _genreDetails;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //initiate the genres array
    NSString *path = path = [[NSBundle mainBundle] pathForResource:@"GenreInformation" ofType:@"plist"];

    NSDictionary *genrePlistInformation = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    //check to see if the genre user defaults have been saved
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"genreInformation"]) {
        
        //if there is genre information in user defaults, set the variables to the stored values
        
        NSDictionary *genreUserDefaultsInformation = [[NSDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"genreInformation"]];
        
        bool userDefaultsDataUpdated = NO;
        
        //if the user defaults has Genre Selection, set to variables
        if([genreUserDefaultsInformation objectForKey:@"genreSelections"]){
            self.genres = [genreUserDefaultsInformation objectForKey:@"genreSelections"];
        }
        else{
            self.genres = [genrePlistInformation objectForKey:@"genrePossibleSelections"];
            userDefaultsDataUpdated = YES;
        }
        
        //if the user defaults has Genre Cache, set to variables
        if([genreUserDefaultsInformation objectForKey:@"genreCache"]){
            self.genreData = [genreUserDefaultsInformation objectForKey:@"genreCache"];
        }
        else{
            self.genreData = [[NSMutableDictionary alloc] init];
            userDefaultsDataUpdated = YES;
        }
        
        //if the user defaults data has been updated, store new values 
        if(userDefaultsDataUpdated){
            NSMutableDictionary *genreCache = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.genres,@"genrePossibleSelections",self.genreData,@"genreCache", nil];
            [[NSUserDefaults standardUserDefaults] setObject:genreCache forKey:@"genreInformation"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else{
        //if the genre information is not stored in user defaults, create a new dictionary w/ default data and store
        self.genres = [genrePlistInformation objectForKey:@"genrePossibleSelections"];
        self.genreData = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary *genreCache = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.genres,@"genrePossibleSelections",self.genreData,@"genreCache", nil];
        [[NSUserDefaults standardUserDefaults] setObject:genreCache forKey:@"genreInformation"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //set genre details
    self.genreDetails = [genrePlistInformation objectForKey:@"genreDetails"];
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_OPENED"  object:nil  userInfo: nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
