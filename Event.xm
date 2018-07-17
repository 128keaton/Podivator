#import <libactivator/libactivator.h>
#include <dispatch/dispatch.h>

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
		// Register our event
		if (LASharedActivator.isRunningInsideSpringBoard) {
			[LASharedActivator registerEventDataSource:self forEventName:doubleTapEventName];
			[LASharedActivator registerEventDataSource:self forEventName:tripleTapEventName];
		}
	}
	return self;
}

- (void)dealloc {
	if (LASharedActivator.isRunningInsideSpringBoard) {
		[LASharedActivator unregisterEventDataSourceWithEventName:doubleTapEventName];
		[LASharedActivator unregisterEventDataSourceWithEventName:tripleTapEventName];
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
    NSLog(@"%@", eventName);
	if ([eventName isEqualToString:tripleTapEventName]){
	    return @"Called when you triple tap AirPods";
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

////////////////////////////////////////////////////////////////

// Event dispatch


%hook BluetoothManager

-(void)_postNotificationWithArray:(id)arg1{
       HBLogInfo(@"DEBUG: _postNotificationWithArray: %@", arg1);
       NSLog(@"DEBUG: _postNotificationWithArray: %@", arg1);
}

%end
