//
//  BLPowerCondition.h
//  BetterLogin
//
//  Created by Derek Foresman on 1/25/25.
//

#import <Foundation/Foundation.h>
#import <IOKit/ps/IOPowerSources.h>

#define kPowerConditionChangedNotification  @"BLPowerConditionChanged"

@interface BLPowerCondition : NSObject {
    BOOL listening;
}
- (void)startMonitoringCondition;
- (void)stopMonitoringCondition;
@end
