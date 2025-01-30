//
//  BetterLogin.m
//  BetterLogin
//
//  Created by MTAC on 1/1/22.
//
//

#import "BetterLogin.h"
#import <IOKit/ps/IOPowerSources.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

#include <os/log.h>
#define DLog(N, ...) os_log_with_type(os_log_create("com.mtac.BetterLogin", "DEBUG"),OS_LOG_TYPE_DEFAULT,N ,##__VA_ARGS__)


static NSUserDefaults *defaults;

BOOL containsKey(NSString *key) {
    return [defaults.dictionaryRepresentation.allKeys containsObject:key];
}

static double batteryPercentage(void) {
    CFTypeRef powerSourceInfo = IOPSCopyPowerSourcesInfo();
    CFArrayRef powerSources = IOPSCopyPowerSourcesList(powerSourceInfo);
    CFDictionaryRef powerSource = IOPSGetPowerSourceDescription(powerSourceInfo, CFArrayGetValueAtIndex(powerSources, 0));
    const void *psValue;
    int curCapacity = 0;
    int maxCapacity = 0;
    double percentage;
    psValue = CFDictionaryGetValue(powerSource, CFSTR(kIOPSCurrentCapacityKey));
            CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &curCapacity);
            
    psValue = CFDictionaryGetValue(powerSource, CFSTR(kIOPSMaxCapacityKey));
            CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &maxCapacity);
            
    percentage = (double)curCapacity / (double)maxCapacity;
    return percentage;
}

static void dumpViews(NSView* v, int level) {
    NSString* indent = @"";
    for (int i = 0; i < level; i++) {
        indent = [indent stringByAppendingString:@"    "];
    }
    NSLog(@"[BETTERLOGIN] %@%@ %@", indent, [v class], NSStringFromRect(v.frame));
    if (v.subviews != NULL) {
        for (id s in v.subviews) {
            dumpViews(s, level + 1);
        }
    }
}

static NSString *internetAddress(void) {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];

                }

            }

            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}

BetterLogin *plugin;
static NSMutableDictionary *preferences = nil;

@interface BetterLogin()
@end

@implementation BetterLogin
+ (instancetype)sharedInstance {
    plugin = nil;
    @synchronized(self) {
        if (!plugin) {
            plugin = [[self alloc] init];
        }
    }
    return plugin;
}
+ (void)load {
    plugin = [BetterLogin sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBatteryInfo) name:kPowerConditionChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBatteryInfo) name:NSProcessInfoPowerStateDidChangeNotification object:nil];
    
    BLPowerCondition *condition = [[BLPowerCondition alloc] init];
    [condition startMonitoringCondition];
    
    if (!plugin.batteryImageView) plugin.batteryImageView = [[NSImageView alloc] initWithFrame:CGRectZero];
    plugin.batteryImageView.translatesAutoresizingMaskIntoConstraints = NO;
    plugin.batteryImageView.imageScaling = NSImageScaleProportionallyDown;
    
    if (!plugin.batteryPercentField) plugin.batteryPercentField = [[NSTextField alloc] initWithFrame:CGRectZero];
    plugin.batteryPercentField.translatesAutoresizingMaskIntoConstraints = NO;
    plugin.batteryPercentField.alignment = NSTextAlignmentCenter;
    plugin.batteryPercentField.editable = NO;
    plugin.batteryPercentField.bordered = NO;
    plugin.batteryPercentField.drawsBackground = NO;
    plugin.batteryPercentField.textColor = [NSColor colorWithWhite:0.0 alpha:0.6];
    plugin.batteryPercentField.font = [NSFont systemFontOfSize:12 weight:NSFontWeightBold];
    
    defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.mtac.betterlogin"];
    
    if (!containsKey(@"blurEnabled")) {
        [defaults setObject:@(NO) forKey:@"blurEnabled"];
    }
    if (!containsKey(@"useCustomClockFont")) {
        [defaults setObject:@(NO) forKey:@"useCustomClockFont"];
    }
    if (!containsKey(@"useCustomDateFont")) {
        [defaults setObject:@(NO) forKey:@"useCustomDateFont"];
    }
    if (!containsKey(@"useCustomDateFormat")) {
        [defaults setObject:@(NO) forKey:@"useCustomDateFormat"];
    }
    if (!containsKey(@"hidePasswordPlaceholder")) {
        [defaults setObject:@(NO) forKey:@"hidePasswordPlaceholder"];
    }
    if (!containsKey(@"hidePasswordAuthHints")) {
        [defaults setObject:@(NO) forKey:@"hidePasswordAuthHints"];
    }
    if (!containsKey(@"dateFormat")) {
        [defaults setObject:@"EEEE, MMMM d" forKey:@"dateFormat"];
    }
    if (!containsKey(@"timeSize")) {
        [defaults setObject:@(108) forKey:@"timeSize"];
    }
    if (!containsKey(@"dateSize")) {
        [defaults setObject:@(25) forKey:@"dateSize"];
    }
    if (!containsKey(@"timePosition")) {
        [defaults setObject:@(0) forKey:@"timePosition"];
    }
    if (!containsKey(@"datePosition")) {
        [defaults setObject:@(0) forKey:@"datePosition"];
    }
    if (!containsKey(@"selectedBlurStyle")) {
        [defaults setObject:@(6) forKey:@"selectedBlurStyle"];
    }
    if (!containsKey(@"horizontalOffset")) {
        [defaults setObject:@(-40) forKey:@"horizontalOffset"];
    }
    if (!containsKey(@"verticalOffset")) {
        [defaults setObject:@(6) forKey:@"verticalOffset"];
    }
    if (!containsKey(@"batteryFontSize")) {
        [defaults setObject:@(12) forKey:@"batteryFontSize"];
    }
    
    [defaults synchronize];
    
    [plugin updateBatteryInfo];
}
- (void)updateBatteryInfo {
    kern_return_t result;
    mach_port_t port = 0;
    io_registry_entry_t entry = IOServiceGetMatchingService(port, IOServiceMatching("IOPMPowerSource"));
    CFMutableDictionaryRef rawProperties = NULL;
    result = IORegistryEntryCreateCFProperties(entry, &rawProperties, NULL, 0);
    NSDictionary *properties = (__bridge_transfer NSDictionary *)rawProperties;
    
    BOOL charging = [[properties objectForKey:@"ExternalConnected"] boolValue];
    
    double capacityRemaining = [[properties objectForKey:@"CurrentCapacity"] doubleValue];
    double maxCapacity = [[properties objectForKey:@"MaxCapacity"] doubleValue];
    int percentage = (int)((capacityRemaining / maxCapacity) * 100);
    NSString *percentageString = [NSString stringWithFormat:@"%d", percentage];
    
    [plugin.batteryImageView setImage:[plugin batteryImageWithPercent:(capacityRemaining / maxCapacity) charging:charging]];
    [plugin.batteryPercentField setStringValue:percentageString];
}
- (NSImage *)batteryImageWithPercent:(CGFloat)percent charging:(BOOL)charging {
    NSBundle *mainBundle = [NSBundle bundleWithPath:@"/Library/Application Support/MacEnhance/Plugins/BetterLogin.bundle"];
    NSImage *batteryImage = [[NSImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"battery-light" ofType:@"png"]];
    NSImage *croppedBatteryImage;
    if (charging) {
        croppedBatteryImage = [self image:[self cropImage:batteryImage toWidthPercentage:percent] tintedWithColor:[NSColor greenColor]];
    } else {
        croppedBatteryImage = [self image:[self cropImage:batteryImage toWidthPercentage:percent] tintedWithColor:[NSColor whiteColor]];
    }
    
    if ((NSInteger)(percent * 100) <= 10) {
        croppedBatteryImage = [self image:[self cropImage:batteryImage toWidthPercentage:percent] tintedWithColor:[NSColor redColor]];
    }
     
    NSImage *finalImage = [self overlayImage:batteryImage withImage:croppedBatteryImage];
    return finalImage;
}
- (NSImage *)cropImage:(NSImage *)image toWidthPercentage:(CGFloat)percentage {
    if (!image || percentage <= 0.0 || percentage > 1.0) {
        return nil;
    }
    NSSize originalSize = [image size];
    
    CGFloat croppedWidth = originalSize.width * percentage;
    CGFloat croppedHeight = originalSize.height;
    
    NSRect sourceRect = NSMakeRect(0, 0, croppedWidth, croppedHeight);
    
    NSImage *croppedImage = [[NSImage alloc] initWithSize:NSMakeSize(originalSize.width, croppedHeight)];
    

    [croppedImage lockFocus];
    [image drawInRect:NSMakeRect(0, 0, croppedWidth, croppedHeight)
             fromRect:sourceRect
            operation:NSCompositingOperationCopy
             fraction:1];
    [croppedImage unlockFocus];
    
    return croppedImage;
}
- (NSImage *)overlayImage:(NSImage *)image1 withImage:(NSImage *)image2 {
    if (!image1 || !image2) {
        return nil;
    }
    NSSize finalSize = [image1 size];
    NSImage *resultImage = [[NSImage alloc] initWithSize:finalSize];
    [resultImage lockFocus];
    
    [image1 drawInRect:NSMakeRect(0, 0, finalSize.width, finalSize.height)
              fromRect:NSZeroRect
             operation:NSCompositingOperationSourceOver
              fraction:0.6];
    
    [image2 drawInRect:NSMakeRect(0, 0, finalSize.width, finalSize.height)
              fromRect:NSZeroRect
             operation:NSCompositingOperationSourceOver
              fraction:1.0];
    [resultImage unlockFocus];
    
    return resultImage;
}
- (NSImage *)image:(NSImage *)image tintedWithColor:(NSColor *)tint {
    if (tint) {
        [image lockFocus];
        [tint set];
        NSRect imageRect = {NSZeroPoint, [image size]};
        NSRectFillUsingOperation(imageRect, NSCompositingOperationSourceAtop);
        [image unlockFocus];
    }
    return image;
}
@end

ZKSwizzleInterface(bl_LUI2BigTimeViewController, LUI2BigTimeViewController, NSViewController)
@implementation bl_LUI2BigTimeViewController
- (double)_fontSize { // 108
    BOOL useCustomClockFont = [[defaults objectForKey:@"useCustomClockFont"] boolValue];
    return useCustomClockFont ? [[defaults objectForKey:@"timeSize"] doubleValue] : ZKOrig(double);
}
@end

ZKSwizzleInterface(bl_LUI2DateViewController, LUI2DateViewController, NSViewController)
@implementation bl_LUI2DateViewController
- (void)viewDidLoad {
    ZKOrig(void);
    if ([[defaults objectForKey:@"useCustomDateFormat"] boolValue]) {
        [self _timerFired];
    }
    
    if ([[defaults objectForKey:@"useCustomDateFont"] boolValue]) {
        NSTextField *dateField = ((LUI2DateViewController *)self).dateTextField;
        [dateField setFont:[dateField.font fontWithSize:[[defaults objectForKey:@"dateSize"] doubleValue]]];
    }
}
- (void)_timerFired {
    if ([[defaults objectForKey:@"useCustomDateFont"] boolValue]) {
        NSTextField *dateField = ((LUI2DateViewController *)self).dateTextField;
        [dateField setFont:[dateField.font fontWithSize:[[defaults objectForKey:@"dateSize"] doubleValue]]];
    }
    
    if ([[defaults objectForKey:@"useCustomDateFormat"] boolValue]) {
        NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
        [formatter setDateFormat:[defaults objectForKey:@"dateFormat"]];
        NSString *dateString = [formatter stringFromDate:NSDate.date];
        NSTextField *dateField = ZKHookIvar(self, NSTextField *, "_dateTextField");
        [dateField setStringValue:dateString];
    } else ZKOrig(void);
}
+ (double)fontSize { // 25
    BOOL useCustomDateFont = [[defaults objectForKey:@"useCustomDateFont"] boolValue];
    return useCustomDateFont ? [[defaults objectForKey:@"dateSize"] doubleValue] : ZKOrig(double);
}
@end

ZKSwizzleInterface(bl_LUI2DarkenView, LUI2DarkenView, NSView)
@implementation bl_LUI2DarkenView
- (double)opacity {
    return 0.15;
}
@end

ZKSwizzleInterface(bl_LUI2BatteryView, LUI2BatteryView, NSView)
@implementation bl_LUI2BatteryView
- (void)setBatteryPercentage:(id)percentage {
    ZKOrig(void, percentage);
    [((LUI2BatteryView *)self).batteryImageView setHidden:YES];
    [((LUI2BatteryView *)self).batteryTextField setHidden:YES];
}
@end

ZKSwizzleInterface(bl_LUI2TintView, LUI2TintView, NSView)
@implementation bl_LUI2TintView
- (BOOL)isEnabled {
    return NO;
}
@end

ZKSwizzleInterface(bl_LUI2InputMethodViewController, LUI2InputMethodViewController, NSViewController)
@implementation bl_LUI2InputMethodViewController
- (void)viewDidLoad {
    ZKOrig(void);
    NSButton *inputButton = ZKHookIvar(self, NSButton *, "_textInputButton");
    inputButton.hidden = YES;
    inputButton.alphaValue = 0.0;
}
- (void)setEnabled:(BOOL)arg1 {
    ZKOrig(void, NO);
}
@end

ZKSwizzleInterface(bl_LUI2ScreenLockController, LUI2ScreenLockController, NSObject)
@implementation bl_LUI2ScreenLockController
- (void)viewDidLoad {
    ZKOrig(void);
}
- (double)_bigTimeConstraintConstant {
    return ZKOrig(double) + [[defaults objectForKey:@"timePosition"] doubleValue];
}
- (double)_dateConstraintConstant {
    return ZKOrig(double) + [[defaults objectForKey:@"datePosition"] doubleValue];
}
@end

ZKSwizzleInterface(bl_LUI2BackgroundViewController, LUI2BackgroundViewController, NSViewController)
@implementation bl_LUI2BackgroundViewController
- (void)viewDidLoad {
    ZKOrig(void);

    NSInteger selectedBlurStyle = [[defaults objectForKey:@"selectedBlurStyle"] integerValue];
    
    NSVisualEffectView *vibrant = [[NSVisualEffectView alloc] initWithFrame:self.view.frame];
    [vibrant setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [vibrant setBlendingMode:NSVisualEffectBlendingModeWithinWindow];
    [vibrant setMaterial:(NSVisualEffectMaterial)selectedBlurStyle];
    [vibrant setState:NSVisualEffectStateActive];
    [self.view addSubview:vibrant positioned:NSWindowBelow relativeTo:self.view];
    
    [vibrant setHidden:![[defaults objectForKey:@"blurEnabled"] boolValue]];
    
    NSButton *settingsButton = [[NSButton alloc] init];
    settingsButton.image = [NSImage imageWithSystemSymbolName:@"gearshape.fill" accessibilityDescription:@""];
    settingsButton.alphaValue = 0.25;
    settingsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [settingsButton setTarget:self];
    [settingsButton setAction:@selector(openSettings:)];
    [settingsButton setButtonType:NSButtonTypeMomentaryPushIn];
    [settingsButton setBordered:NO];
    [settingsButton setBezelStyle:NSBezelStyleRegularSquare];
    [settingsButton setImageScaling:NSImageScaleProportionallyUpOrDown];
    [self.view addSubview:settingsButton];
    [self.view addSubview:plugin.batteryImageView];
    [self.view addSubview:plugin.batteryPercentField];
    
    [NSLayoutConstraint activateConstraints:@[
        [plugin.batteryImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:[[defaults objectForKey:@"horizontalOffset"] integerValue]],
        [plugin.batteryImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:[[defaults objectForKey:@"verticalOffset"] integerValue]],
        [plugin.batteryImageView.widthAnchor constraintEqualToConstant:32],
        [plugin.batteryImageView.heightAnchor constraintEqualToConstant:20],
        [plugin.batteryPercentField.centerYAnchor constraintEqualToAnchor:plugin.batteryImageView.centerYAnchor constant:2],
        [plugin.batteryPercentField.heightAnchor constraintEqualToConstant:20],
        [plugin.batteryPercentField.leadingAnchor constraintEqualToAnchor:plugin.batteryImageView.leadingAnchor],
        [plugin.batteryPercentField.trailingAnchor constraintEqualToAnchor:plugin.batteryImageView.trailingAnchor constant:-2],
        [settingsButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:6],
        [settingsButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10],
        [settingsButton.widthAnchor constraintEqualToConstant:20],
        [settingsButton.heightAnchor constraintEqualToConstant:20],
    ]];
    
    [plugin updateBatteryInfo];
}
- (void)openSettings:(id)sender {
    LUI2PopoverViewController *popover = [[NSClassFromString(@"LUI2PopoverViewController") alloc] init];
    popover.preferredContentSize = CGSizeMake(300, 400);
    [popover presentUsingViewController:self asPopoverRelativeToRect:CGRectMake(10, 6, 20, 20) ofView:self.view preferredEdge:NSMinYEdge behavior:NSPopoverBehaviorTransient];
}
@end

ZKSwizzleInterface(bl_LWDefaultScreenLockUI, LWDefaultScreenLockUI, NSObject)
@implementation bl_LWDefaultScreenLockUI
- (void)setPasswordFieldPlaceholderString:(NSString *)arg1 {
    BOOL hidePasswordPlaceholder = [[defaults objectForKey:@"hidePasswordPlaceholder"] boolValue];
    ZKOrig(void, (hidePasswordPlaceholder) ? @"" : arg1);
}
- (NSString *)goodSamaritanMessage {
    // NSString *message = [NSString stringWithFormat:@"Battery: %d%%", batteryPercentage()];
    return @"";
}
- (void)_setAuthHintText:(id)text subHintText:(id)hint {
    BOOL hidePasswordAuthHints = [[defaults objectForKey:@"hidePasswordAuthHints"] boolValue];
    ZKOrig(void, hidePasswordAuthHints ? @"" : text, hidePasswordAuthHints ? @"" : hint);
}
@end

/* ZKSwizzleInterface(bl_LUIMessageViewController, LUIMessageViewController, NSViewController)
@implementation bl_LUIMessageViewController
- (void)setMessage:(id)arg0 {
    NSString *message = [NSString stringWithFormat:@"Battery: %d%%", batteryPercentage()];
    ZKOrig(void, message);
}
@end

ZKSwizzleInterface(bl_LUISecureTextField, LUISecureTextField, NSTextField)
@implementation LUISecureTextField
- (id)initWithFrame:(CGRect)arg1 {
    self = ZKOrig(id, arg1);
    [(NSTextField *)self setBezeled:NO];
    [(NSTextField *)self setDrawsBackground:NO];
    return self;
}
@end */

/*ZKSwizzleInterface(bl_UserInfo, UserInfo, NSObject)
@implementation bl_UserInfo
- (NSString *)longName {
    NSString *name = ZKOrig(NSString *);
    if ([[defaults objectForKey:@"nameEnabled"] boolValue]) {
        return [defaults objectForKey:@"accountName"] ?: name;
    }
    return name;
}
- (NSImage *)userPicture {
    if ([[defaults objectForKey:@"pictureEnabled"] boolValue]) {
        return [NSImage new];
    }
    return ZKOrig(NSImage *);
}
@end */

/* ZKSwizzleInterface(bl_LUI2MessageViewController, LUI2MessageViewController, NSViewController)
@implementation bl_LUI2MessageViewController
- (void)viewDidLoad {
    ZKOrig(void);
    NSLayoutConstraint *constraint = ((LUI2MessageViewController *)self).messageTextViewHeightConstraint;
    ((LUI2MessageViewController *)self).messageTextViewHeightConstraint.constant = constraint.constant * 2;
    // CGRect viewFrame = self.view.frame; // 46 x 24
    NSImageView *batteryImageView = [[NSImageView alloc] initWithFrame:CGRectZero];
    batteryImageView.translatesAutoresizingMaskIntoConstraints = NO;
    batteryImageView.imageScaling = NSImageScaleProportionallyDown;
    
    [self.view addSubview:batteryImageView];
    [batteryImageView setImage:[self batteryImageWithPercent:batteryPercentage()]];
    
    NSTextField *batteryPercentField = [[NSTextField alloc] initWithFrame:CGRectZero];
    batteryPercentField.translatesAutoresizingMaskIntoConstraints = NO;
    batteryPercentField.font = [NSFont systemFontOfSize:18 weight:NSFontWeightSemibold];
    batteryPercentField.alignment = NSTextAlignmentCenter;
    batteryPercentField.editable = NO;
    batteryPercentField.bordered = NO;
    batteryPercentField.drawsBackground = NO;
    // batteryPercentField.cell = [AMPTextFieldCell new];
    batteryPercentField.textColor = [NSColor colorWithWhite:0.0 alpha:0.6];
    [batteryPercentField setStringValue:[NSString stringWithFormat:@"%d", (int)(batteryPercentage() * 100)]];
    [self.view addSubview:batteryPercentField];
    
    [NSLayoutConstraint activateConstraints:@[
        [batteryImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [batteryImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [batteryImageView.widthAnchor constraintEqualToConstant:46],
        [batteryImageView.heightAnchor constraintEqualToConstant:24],
        [batteryPercentField.centerYAnchor constraintEqualToAnchor:batteryImageView.centerYAnchor constant:2],
        [batteryPercentField.heightAnchor constraintEqualToConstant:24],
        [batteryPercentField.leadingAnchor constraintEqualToAnchor:batteryImageView.leadingAnchor],
        [batteryPercentField.trailingAnchor constraintEqualToAnchor:batteryImageView.trailingAnchor constant:-4],
    ]];
}
@end */

/* ZKSwizzleInterface(bl_LUI2UserView, LUI2UserView, NSView)
@implementation bl_LUI2UserView
- (id)initWithFrame:(struct CGRect)arg1 usingVisualEffectBackground:(BOOL)arg2 {
    return ZKOrig(id, arg1, YES);
}
- (id)initWithFrame:(struct CGRect)arg1 {
    return [self initWithFrame:arg1 usingVisualEffectBackground:YES];
}
@end */

/* ZKSwizzleInterface(bl_LUI2UserViewController, LUI2UserViewController, NSViewController)
@implementation bl_LUI2UserViewController
- (void)_createUserView {
    ZKOrig(void);
    LUI2UserView *userView = ZKHookIvar(self, LUI2UserView *, "_userView");
    NSVisualEffectView *vibrant = [[NSVisualEffectView alloc] initWithFrame:userView.frame];
    [vibrant setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [vibrant setBlendingMode:NSVisualEffectBlendingModeWithinWindow];
    [vibrant setMaterial:NSVisualEffectMaterialSidebar];
    [vibrant setState:NSVisualEffectStateActive];
    [vibrant setWantsLayer:YES];
    [vibrant.layer setMasksToBounds:YES];
    [vibrant.layer setCornerRadius:20];
    [self.view addSubview:vibrant positioned:NSWindowBelow relativeTo:userView];
}
@end */

/*

ZKSwizzleInterface(bl_LWAuthServiceState, LWAuthServiceState, NSObject)
@implementation bl_LWAuthServiceState
- (id)_stringForServiceState:(unsigned long long)arg1 {
    NSString *state = ZKOrig(id, arg1);
    if ([[defaults objectForKey:@"hintsEnabled"] boolValue]) {
        return @" ";
    }
    return state;
}
- (id)_displayMessageForMessage:(id)arg1 combinedWithMessage:(id)arg2 {
    NSString *state = ZKOrig(id, arg1, arg2);
    if ([[defaults objectForKey:@"hintsEnabled"] boolValue]) {
        return @" ";
    }
    return state;
}
@end

ZKSwizzleInterface(bl_LUI2BatteryView, LUI2BatteryView, NSStackView)
@implementation bl_LUI2BatteryView
- (void)_setupBatteryView {
    ZKOrig(void);
    if ([[defaults objectForKey:@"colorsEnabled"] boolValue]) {
        NSImageView *batteryImageView = ZKHookIvar(self, NSImageView *, "_batteryImageView");
        int percentage = batteryPercentage();
        if (percentage <= 20) {
            [batteryImageView setContentTintColor:[NSColor systemRedColor]];
        } else if (percentage > 20 && percentage < 40) {
            [batteryImageView setContentTintColor:[NSColor systemYellowColor]];
        } else if (percentage > 40) {
            [batteryImageView setContentTintColor:[NSColor systemGreenColor]];
        }
    }
}
@end

ZKSwizzleInterface(bl_LUI2GlyphButton, LUI2GlyphButton, NSView)
@implementation bl_LUI2GlyphButton
- (void)_setupButtonView {
    ZKOrig(void);
    if ([[defaults objectForKey:@"cancelTitleEnabled"] boolValue]) {
        NSTextField *textField = ZKHookIvar(self, NSTextField *, "_titleView");
        [textField setStringValue:@""];
    }
}
@end */

/* ZKSwizzleInterface(bl_LUI2Window, LUI2Window, NSWindow)
@implementation bl_LUI2Window
- (void)orderFront:(id)arg1 {
    ZKOrig(void, arg1);
    
    NSVisualEffectView *vibrant = [[NSVisualEffectView alloc] initWithFrame:[self.contentView bounds]];
    [vibrant setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [vibrant setBlendingMode:NSVisualEffectBlendingModeWithinWindow];
    [vibrant setMaterial:NSVisualEffectMaterialSidebar];
    [vibrant setState:NSVisualEffectStateActive];
    [vibrant setAlphaValue:0.5];
    [self.contentView addSubview:vibrant positioned:NSWindowBelow relativeTo:self.contentView.subviews.firstObject];
}
@end */


