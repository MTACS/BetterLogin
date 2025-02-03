//
//  AppDelegate.m
//  BetterLoginApp
//
//  Created by MTAC on 8/2/23.
//

#import "AppDelegate.h"
#import <dlfcn.h>

extern void SACLockScreenImmediate(void);

@interface AppDelegate ()
@end

@implementation AppDelegate
- (IBAction)applyChanges:(NSButton *)sender {
    void *handle = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY);
    if (handle) {
        void (*SACLockScreenImmediate)(void) = dlsym(handle, "SACLockScreenImmediate");
        if (SACLockScreenImmediate) {
            SACLockScreenImmediate();
        }
    }
}
- (IBAction)showAboutView:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLShowAboutView" object:nil];
}
- (IBAction)resetPreferences:(NSButton *)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Reset All Preferences?"];
    [alert addButtonWithTitle:@"Confirm"];
    [alert addButtonWithTitle:@"Cancel"];

    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.mtac.betterlogin"];
    } else if (button == NSAlertSecondButtonReturn) {
        return;
    }
}
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
