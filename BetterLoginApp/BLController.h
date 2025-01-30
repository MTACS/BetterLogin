//
//  BLController.h
//  BetterLoginApp
//
//  Created by MTAC on 8/2/23.
//

#import <Cocoa/Cocoa.h>

@interface BLController : NSViewController <NSTextFieldDelegate>
@property (strong) IBOutlet NSSwitch *blurSwitch;
@property (strong) IBOutlet NSSwitch *clockFontSwitch;
@property (strong) IBOutlet NSSwitch *dateFontSwitch;
@property (strong) IBOutlet NSSwitch *dateFormatSwitch;
@property (strong) IBOutlet NSSwitch *placeholderSwitch;
@property (strong) IBOutlet NSSwitch *authHintSwitch;
@property (strong) IBOutlet NSPopUpButton *blurStyleButton;
@property (strong) IBOutlet NSTextField *clockSizeInput;
@property (strong) IBOutlet NSTextField *clockPositionInput;
@property (strong) IBOutlet NSTextField *dateSizeInput;
@property (strong) IBOutlet NSTextField *datePositionInput;
@property (strong) IBOutlet NSTextField *dateFormatInput;
@property (strong) IBOutlet NSStepper *clockSizeStepper;
@property (strong) IBOutlet NSStepper *clockPositionStepper;
@property (strong) IBOutlet NSStepper *dateSizeStepper;
@property (strong) IBOutlet NSStepper *datePositionStepper;
@end

