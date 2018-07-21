#line 1 "Event.xm"
#import <libactivator/libactivator.h>
#include <dispatch/dispatch.h>
#import "MediaRemote.h"

@interface MPMusicPlayerController
+ (id)systemMusicPlayer;
- (void)play;
- (void)skipToNextItem;
@end


#define LASendEventWithName(eventName) \
[LASharedActivator sendEventToListener:[LAEvent eventWithName:eventName mode:[LASharedActivator currentEventMode]]]

static NSString *doubleTapEventName = @"Double Tap AirPods";
static NSString *tripleTapEventName = @"Triple Tap AirPods";


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
        
        if (LASharedActivator.isRunningInsideSpringBoard) {
            [LASharedActivator registerEventDataSource:self forEventName:doubleTapEventName];
            
        }
    }
    return self;
}

- (void)dealloc {
    if (LASharedActivator.isRunningInsideSpringBoard) {
        [LASharedActivator unregisterEventDataSourceWithEventName:doubleTapEventName];
        
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
    if ([eventName isEqualToString:tripleTapEventName]){
        return @"Called when you triple tap AirPods";
    }else{
        return @"Called when you double tap AirPods";
    }
    return @"";
}










- (BOOL)eventWithName:(NSString *)eventName isCompatibleWithMode:(NSString *)eventMode {
    return YES;
}






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

static __attribute__((constructor)) void _logosLocalCtor_1f8737e1(int __unused argc, char __unused **argv, char __unused **envp){
    mediaControl = [[MediaControl11 alloc] init];
    [[LAActivator sharedInstance] registerListener:mediaControl
                                           forName:@"audio-control-next-track"];
}








#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class BluetoothManager; 
static void (*_logos_orig$_ungrouped$BluetoothManager$postNotificationName$object$)(_LOGOS_SELF_TYPE_NORMAL BluetoothManager* _LOGOS_SELF_CONST, SEL, id, id); static void _logos_method$_ungrouped$BluetoothManager$postNotificationName$object$(_LOGOS_SELF_TYPE_NORMAL BluetoothManager* _LOGOS_SELF_CONST, SEL, id, id); 

#line 125 "Event.xm"


static void _logos_method$_ungrouped$BluetoothManager$postNotificationName$object$(_LOGOS_SELF_TYPE_NORMAL BluetoothManager* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1, id arg2) {
    if ([arg1 isEqualToString: @"BluetoothHandsfreeInitiatedVoiceCommand"]){
        LAEvent *doubleTapEvent = [LAEvent eventWithName:doubleTapEventName mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:doubleTapEvent];
        
        if (doubleTapEvent.handled){
            HBLogInfo(@"Podivator activate");
            NSLog(@"Podivator activate");
            return;
        }
    }
    
    _logos_orig$_ungrouped$BluetoothManager$postNotificationName$object$(self, _cmd, arg1, arg2);
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$BluetoothManager = objc_getClass("BluetoothManager"); MSHookMessageEx(_logos_class$_ungrouped$BluetoothManager, @selector(postNotificationName:object:), (IMP)&_logos_method$_ungrouped$BluetoothManager$postNotificationName$object$, (IMP*)&_logos_orig$_ungrouped$BluetoothManager$postNotificationName$object$);} }
#line 143 "Event.xm"
