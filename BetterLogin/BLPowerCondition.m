//
//  BLPowerCondition.m
//  BetterLogin
//
//  Created by Derek Foresman on 1/25/25.
//

#import "BLPowerCondition.h"

static NSUInteger PowerChangeListenerCount = 0;
static CFRunLoopSourceRef PowerChangeSource = NULL;
static void PowerChangeCallback(void *context) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPowerConditionChangedNotification object:nil];
}

@implementation BLPowerCondition
- (void)startMonitoringCondition {
    if (!listening) {
        if (PowerChangeListenerCount++==0) {
            
            PowerChangeSource = IOPSNotificationCreateRunLoopSource(PowerChangeCallback,NULL);
            CFRunLoopAddSource([[NSRunLoop mainRunLoop] getCFRunLoop],PowerChangeSource,kCFRunLoopCommonModes);
            }
        listening = YES;
    }
}
- (void)stopMonitoringCondition {
    if (listening) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if (--PowerChangeListenerCount==0) {
            CFRunLoopRemoveSource([[NSRunLoop mainRunLoop] getCFRunLoop],PowerChangeSource,kCFRunLoopCommonModes);
            CFRelease(PowerChangeSource);
            PowerChangeSource = NULL;
            listening = NO;
        }
    }
}
@end
