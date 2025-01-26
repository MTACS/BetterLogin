//
//  BLController.h
//  BetterLoginApp
//
//  Created by MTAC on 8/2/23.
//

#import <Cocoa/Cocoa.h>

@interface BLController : NSViewController <NSTextFieldDelegate>
@property (strong) IBOutlet NSSwitch *enableSwitch;
@property (strong) IBOutlet NSSwitch *blurSwitch;
@property (strong) IBOutlet NSSwitch *internetSwitch;
@property (strong) IBOutlet NSSwitch *percentageSwitch;
@property (strong) IBOutlet NSSwitch *colorsSwitch;
@property (strong) IBOutlet NSSwitch *nameSwitch;
@property (strong) IBOutlet NSSwitch *pictureSwitch;
@property (strong) IBOutlet NSSwitch *placeholderSwitch;
@property (strong) IBOutlet NSSwitch *hintSwitch;
@property (strong) IBOutlet NSSwitch *cancelButtonSwitch;

@property (strong) IBOutlet NSTextField *nameLabel;
@end

