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

static NSUserDefaults *defaults;

BOOL containsKey(NSString *key) {
    return [defaults.dictionaryRepresentation.allKeys containsObject:key];
}

static double batteryPercentage() {
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

static NSString *internetAddress() {
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

@interface AMPTextFieldCell : NSTextFieldCell
@end

@implementation AMPTextFieldCell
- (NSRect)titleRectForBounds:(NSRect)frame {
    CGFloat stringHeight = self.attributedStringValue.size.height;
    CGFloat stringWidth = self.attributedStringValue.size.width;
    NSRect titleRect = [super titleRectForBounds:frame];
    CGFloat originY = frame.origin.y;
    CGFloat originX = frame.origin.x;
    titleRect.origin.y = frame.origin.y + (frame.size.height - stringHeight) / 2.0;
    titleRect.size.height = titleRect.size.height - (titleRect.origin.y - originY);
    titleRect.origin.x = frame.origin.x + (frame.size.width - stringWidth) / 2.0;
    titleRect.size.width = titleRect.size.width - (titleRect.origin.x - originX);
    return titleRect;
}
- (void)drawInteriorWithFrame:(NSRect)cFrame inView:(NSView*)cView {
    [super drawInteriorWithFrame:[self titleRectForBounds:cFrame] inView:cView];
}
@end

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
    defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.mtac.betterlogin"];
    if (!containsKey(@"horizontalOffset")) {
        [defaults setObject:@(-40) forKey:@"horizontalOffset"];
    }
    if (!containsKey(@"verticalOffset")) {
        [defaults setObject:@(6) forKey:@"verticalOffset"];
    }
    if (!containsKey(@"batteryFontSize")) {
        [defaults setObject:@(12) forKey:@"batteryFontSize"];
    }
    if (!containsKey(@"timeSize")) {
        [defaults setObject:@(81) forKey:@"timeSize"];
    }
    if (!containsKey(@"dateSize")) {
        [defaults setObject:@(18.75) forKey:@"dateSize"];
    }
    if (!containsKey(@"selectedBlurStyle")) {
        [defaults setObject:@(6) forKey:@"selectedBlurStyle"];
    }
    [defaults synchronize];
}
- (id)init {
    self = [super init];
    if (!self) return nil;
    return self;
}
@end

ZKSwizzleInterface(bl_LUI2BigTimeViewController, LUI2BigTimeViewController, NSViewController)
@implementation bl_LUI2BigTimeViewController
- (double)_fontSize { // 108
    return [[defaults objectForKey:@"timeSize"] doubleValue];
}
@end

ZKSwizzleInterface(bl_LUI2DateViewController, LUI2DateViewController, NSViewController)
@implementation bl_LUI2DateViewController
- (void)viewDidLoad {
    ZKOrig(void);
    [self _timerFired];
    // NSTextField *dateField = ZKHookIvar(self, NSTextField *, "_dateTextField");
    // [dateField setHidden:YES];
}
- (void)_timerFired {
    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d"];
    NSString *dateString = [formatter stringFromDate:NSDate.date];
    NSTextField *dateField = ZKHookIvar(self, NSTextField *, "_dateTextField");
    [dateField setStringValue:dateString];
}
+ (double)fontSize { // 25
    return [[defaults objectForKey:@"dateSize"] doubleValue];
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
    for (NSWindow *window in [[NSApplication sharedApplication] windows]) {
        dumpViews([window contentView], 0);
    }
}
- (double)_bigTimeConstraintConstant {
    return ZKOrig(double);
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
    
    NSButton *blurSettings = [[NSButton alloc] init];
    blurSettings.image = [NSImage imageWithSystemSymbolName:@"gearshape.fill" accessibilityDescription:@""];
    blurSettings.alphaValue = 0.25;
    blurSettings.translatesAutoresizingMaskIntoConstraints = NO;
    [blurSettings setTarget:self];
    [blurSettings setAction:@selector(openSettings:)];
    [blurSettings setButtonType:NSButtonTypeMomentaryPushIn];
    [blurSettings setBordered:NO];
    [blurSettings setBezelStyle:NSBezelStyleRegularSquare];
    [blurSettings setImageScaling:NSImageScaleProportionallyUpOrDown];
    [self.view addSubview:blurSettings];
    
    NSImageView *batteryImageView = [[NSImageView alloc] initWithFrame:CGRectZero];
    batteryImageView.translatesAutoresizingMaskIntoConstraints = NO;
    batteryImageView.imageScaling = NSImageScaleProportionallyDown;
    
    [self.view addSubview:batteryImageView];
    [batteryImageView setImage:[self batteryImageWithPercent:batteryPercentage()]];
    
    NSTextField *batteryPercentField = [[NSTextField alloc] initWithFrame:CGRectZero];
    batteryPercentField.translatesAutoresizingMaskIntoConstraints = NO;
    batteryPercentField.font = [NSFont systemFontOfSize:[[defaults objectForKey:@"batteryFontSize"] integerValue] weight:NSFontWeightBold];
    batteryPercentField.alignment = NSTextAlignmentCenter;
    batteryPercentField.editable = NO;
    batteryPercentField.bordered = NO;
    batteryPercentField.drawsBackground = NO;
    // batteryPercentField.cell = [AMPTextFieldCell new];
    batteryPercentField.textColor = [NSColor colorWithWhite:0.0 alpha:0.6];
    [batteryPercentField setStringValue:[NSString stringWithFormat:@"%d", (int)(batteryPercentage() * 100)]];
    [self.view addSubview:batteryPercentField];
    
    [NSLayoutConstraint activateConstraints:@[
        [batteryImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:[[defaults objectForKey:@"horizontalOffset"] integerValue]],
        [batteryImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:[[defaults objectForKey:@"verticalOffset"] integerValue]],
        [batteryImageView.widthAnchor constraintEqualToConstant:32],
        [batteryImageView.heightAnchor constraintEqualToConstant:20],
        [batteryPercentField.centerYAnchor constraintEqualToAnchor:batteryImageView.centerYAnchor constant:2],
        [batteryPercentField.heightAnchor constraintEqualToConstant:20],
        [batteryPercentField.leadingAnchor constraintEqualToAnchor:batteryImageView.leadingAnchor],
        [batteryPercentField.trailingAnchor constraintEqualToAnchor:batteryImageView.trailingAnchor constant:-2],
        [blurSettings.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:6],
        [blurSettings.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10],
        [blurSettings.widthAnchor constraintEqualToConstant:20],
        [blurSettings.heightAnchor constraintEqualToConstant:20],
    ]];
}
- (NSImage *)batteryImageWithPercent:(CGFloat)percent {
    NSBundle *mainBundle = [NSBundle bundleWithPath:@"/Library/Application Support/MacEnhance/Plugins/BetterLogin.bundle"];
    NSImage *batteryImage = [[NSImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"battery-light" ofType:@"png"]];
    NSImage *croppedBatteryImage = [self image:[self cropImage:batteryImage toWidthPercentage:percent] tintedWithColor:[NSColor whiteColor]];
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
- (void)openSettings:(id)sender {
    BetterLoginWindowController *windowController = [[BetterLoginWindowController alloc] init];
    [windowController showWindow:[NSApplication sharedApplication]];
}
@end

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

ZKSwizzleInterface(bl_LWDefaultScreenLockUI, LWDefaultScreenLockUI, NSObject)
@implementation bl_LWDefaultScreenLockUI
- (void)setPasswordFieldPlaceholderString:(NSString *)arg1 {
    ZKOrig(void, @"");
}
- (NSString *)goodSamaritanMessage {
    // NSString *message = [NSString stringWithFormat:@"Battery: %d%%", batteryPercentage()];
    return @"";
}
- (void)_setAuthHintText:(id)text subHintText:(id)hint {
    ZKOrig(void, @"", @"");
}
@end

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


