#import <libactivator/libactivator.h>
#include <dispatch/dispatch.h>
#import "MediaRemote.h"

interface TUCallCenter
+ (instancetype)sharedInstance;
- (BOOL)inCall;
@end

@interface MPMusicPlayerController
+ (id)systemMusicPlayer;
- (void)play;
- (void)skipToNextItem;
@end


#define LASendEventWithName(eventName) \
[LASharedActivator sendEventToListener:[LAEvent eventWithName:eventName mode:[LASharedActivator currentEventMode]]]

static NSString *doubleTapEventName = @"Double Tap AirPods";
static NSString *quadTapEventName = @"Quadtruple Tap AirPods";


@interface PodivatorDataSource : NSObject <LAEventDataSource> {}

+ (id)sharedInstance;

@end

@implementation PodivatorDataSource

+ (id)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

+ (void)load {
    [self sharedInstance];
}

- (id)init {
    if ((self = [super init])) {
        // Register our event
        if (LASharedActivator.isRunningInsideSpringBoard) {
            [LASharedActivator registerEventDataSource:self forEventName:doubleTapEventName];
            [LASharedActivator registerEventDataSource:self forEventName:quadTapEventName];
        }
    }
    return self;
}

- (void)dealloc {
    if (LASharedActivator.isRunningInsideSpringBoard) {
        [LASharedActivator unregisterEventDataSourceWithEventName:doubleTapEventName];
        [LASharedActivator unregisterEventDataSourceWithEventName:quadTapEventName];
    }
    [super dealloc];
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
    return eventName;
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
    return @"AirPods";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
    NSLog(@"DEBUG: %@", eventName);
    HBLogInfo(@"DEBUG: %@", eventName);
    if ([eventName isEqualToString:quadTapEventName]){
        return @"Called when you quadtruple tap AirPods";
    }else{
        return @"Called when you double tap AirPods";
    }
    return @"";
}
/*
 - (BOOL)eventWithNameIsHidden:(NSString *)eventName {
 return NO;
 }
 */
/*
 - (BOOL)eventWithNameRequiresAssignment:(NSString *)eventName {
 return NO;
 }
 */
- (BOOL)eventWithName:(NSString *)eventName isCompatibleWithMode:(NSString *)eventMode {
    return YES;
}
/*
 - (BOOL)eventWithNameSupportsUnlockingDeviceToSend:(NSString *)eventName {
 return NO;
 }
 */

@end

@interface MediaControl11 : NSObject <LAListener>
@end

@implementation MediaControl11

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName{
    MRMediaRemoteSendCommand(kMRNextTrack, 0);
    [NSThread sleepForTimeInterval:1.0f];
}

@end


static MediaControl11 *mediaControl;

%ctor{
    mediaControl = [[MediaControl11 alloc] init];
    [[LAActivator sharedInstance] registerListener:mediaControl
                                           forName:@"audio-control-next-track"];
}


////////////////////////////////////////////////////////////////

// Event dispatch

@interface BluetoothManager
-(void)activatorActionForTaps:(int)taps;
@end


%hook BluetoothManager

BOOL didTap = YES;
NSTimer *awaitSecondTap;
BOOL inCall = [[TUCallCenter sharedInstance] inCall];

-(void)handleTimer:(NSTimer*)timer{
    int taps = [timer.userInfo intValue];
    [self activatorActionForTaps: taps];
}

-(void)activatorActionForTaps:(int)taps {
    LAEvent *doubleTapEvent = [LAEvent eventWithName:doubleTapEventName mode:[LASharedActivator currentEventMode]];
    LAEvent *quadTapEvent = [LAEvent eventWithName:quadTapEventName mode:[LASharedActivator currentEventMode]];
    
    if (taps == 4){
        [LASharedActivator sendEventToListener:quadTapEvent];
        return;
    }
    [LASharedActivator sendEventToListener:doubleTapEvent];
    
}

-(void)postNotificationName:(id)arg1 object:(id)arg2 {
    if ([arg1 isEqualToString: @"BluetoothHandsfreeInitiatedVoiceCommand"] && inCall == false){
        if (didTap) {
            [self activatorActionForTaps: 4];
            [awaitSecondTap invalidate];
            didTap = NO;
        }else{
            didTap = YES;
            [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(handleTimer:) userInfo:@"2" repeats:NO];
            didTap = NO;
        }
        return;
    }
    
    %orig(arg1, arg2);
}

%end
