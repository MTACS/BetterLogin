//
//  BLWindow.m
//  BetterLogin
//
//  Created by DF on 1/24/25.
//

#import "BLWindow.h"

@implementation BLWindow
- (id)init {
    self = [super init];
    if (self) {
        self.canBecomeVisibleWithoutLogin = YES;
    }
    return self;
}
@end
