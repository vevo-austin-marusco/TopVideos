#define kKeepAliveInterval 60 /* Seconds in a minute */ * 20 /* 20 minutes */
#define kHeartbeatStageOneInterval 10 /* Seconds */
#define kHeartbeatCountForStateSwitch 6 /* 6 heartbeats - 1 minute */
#define kHeartbeatStageTwoInterval 60 /* Seconds */
#define kPausedOnBufferingInterval 0.5f /* 500 ms */
#define kPausePlaySwitchDelay 0.5f /* 500 ms */

#define kStreamSenseVersion @"4.1303.15"
#define kStreamSenseMovieAdaptorVersion @"4.1303.05"

#define kC1Value @"19"

typedef enum {
    CSStreamSenseStateIdle,
    CSStreamSenseStatePlaying,
    CSStreamSenseStatePaused,
    CSStreamSenseStateBuffering
} CSStreamSenseState;

extern NSString* const CSStreamSenseState_toString[4];
