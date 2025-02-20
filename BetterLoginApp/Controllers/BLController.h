//
//  BLController.h
//  BetterLoginApp
//
//  Created by MTAC on 8/2/23.
//

#import <Cocoa/Cocoa.h>

@interface BLController : NSViewController <NSTextFieldDelegate>
@property (strong) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSSwitch *blurSwitch;
@property (strong) IBOutlet NSSwitch *clockFontSwitch;
@property (strong) IBOutlet NSSwitch *dateFontSwitch;
@property (strong) IBOutlet NSSwitch *dateFormatSwitch;
@property (strong) IBOutlet NSSwitch *placeholderSwitch;
@property (strong) IBOutlet NSSwitch *authHintSwitch;
@property (strong) IBOutlet NSSwitch *customPlaceholderSwitch;
@property (strong) IBOutlet NSSwitch *customClockFontSwitch;
@property (strong) IBOutlet NSSwitch *customDateFontSwitch;
@property (strong) IBOutlet NSSwitch *batterySwitch;
@property (strong) IBOutlet NSSwitch *textInputSwitch;
@property (strong) IBOutlet NSPopUpButton *blurStyleButton;
@property (strong) IBOutlet NSPopUpButton *clockFontButton;
@property (strong) IBOutlet NSPopUpButton *dateFontButton;
@property (strong) IBOutlet NSTextField *clockSizeInput;
@property (strong) IBOutlet NSTextField *clockPositionInput;
@property (strong) IBOutlet NSTextField *dateSizeInput;
@property (strong) IBOutlet NSTextField *datePositionInput;
@property (strong) IBOutlet NSTextField *dateFormatInput;
@property (strong) IBOutlet NSTextField *customPlaceholderInput;
@property (strong) IBOutlet NSStepper *clockSizeStepper;
@property (strong) IBOutlet NSStepper *clockPositionStepper;
@property (strong) IBOutlet NSStepper *dateSizeStepper;
@property (strong) IBOutlet NSStepper *datePositionStepper;
- (void)loadDefaults;
- (void)loadPreferences;
@end

