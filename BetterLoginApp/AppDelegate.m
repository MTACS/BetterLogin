//
//  AppDelegate.m
//  BetterLoginApp
//
//  Created by MTAC on 8/2/23.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
}
- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}
@end
