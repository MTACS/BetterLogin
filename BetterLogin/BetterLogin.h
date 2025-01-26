//
//  BetterLogin.h
//  BetterLogin
//
//  Created by MTAC on 1/1/22.
//
//

#import <Foundation/Foundation.h>
#import "ZKSwizzle/ZKSwizzle.h"
#import "BetterLoginWindowController.h"
#import "BLPowerCondition.h"
#include <dlfcn.h>

#define osx_ver_max [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion
#define osx_ver_min [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion

/* NSVisualEffectMaterialTitlebar = 3,
NSVisualEffectMaterialSelection = 4,
NSVisualEffectMaterialMenu = 5,
NSVisualEffectMaterialPopover = 6,
NSVisualEffectMaterialSidebar = 7,
NSVisualEffectMaterialHeaderView = 10,
NSVisualEffectMaterialSheet = 11,
NSVisualEffectMaterialWindowBackground = 12,
NSVisualEffectMaterialHUDWindow = 13,
NSVisualEffectMaterialFullScreenUI = 15,
NSVisualEffectMaterialToolTip = 17,
NSVisualEffectMaterialContentBackground = 18,
NSVisualEffectMaterialUnderWindowBackground = 21,
NSVisualEffectMaterialUnderPageBackground = 22,
*/

@interface BetterLogin : NSObject
@property (nonatomic, strong) NSImageView *batteryImageView;
@property (nonatomic, strong) NSTextField *batteryPercentField;
+ (instancetype)sharedInstance;
@end

@interface LUI2TextField : NSTextField
@end

@interface LUI2Window: NSWindow
@end

@interface LUISecureTextFieldView : NSView
@end

@interface LUISecureTextFieldCell : NSSecureTextFieldCell
@end

@interface LUI2AuthHintViewController: NSViewController
@end

@interface LUI2ViewController : NSViewController
@end

@interface LUI2UserView : NSView
@end

@interface LUI2TextFieldBackgroundView : NSVisualEffectView
@end

@interface LUI2UserViewController : LUI2ViewController
@property (retain) LUI2UserView *userView;
@end

@interface LUI2DateViewController : LUI2ViewController
@property (retain) NSTextField *dateTextField;
@end

@interface LUI2BatteryView : NSStackView
@property (retain) NSTextField *batteryTextField;
@property (retain) NSImageView *batteryImageView;
@end

@interface LUI2BatteryViewController : LUI2ViewController
@property (retain) LUI2BatteryView *batteryView;
@end

@interface LUI2MessageViewController : LUI2ViewController
@property NSLayoutConstraint *messageTextViewHeightConstraint;
@property (readonly) NSTextView *messageTextView;
@end

@interface LUI2BackgroundViewController : LUI2ViewController
@end
