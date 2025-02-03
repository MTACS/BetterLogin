//
//  BLController.m
//  BetterLoginApp
//
//  Created by MTAC on 8/2/23.
//

#import "BLController.h"

NSUserDefaults *defaults;

BOOL containsKey(NSString *key) {
    return [defaults.dictionaryRepresentation.allKeys containsObject:key];
}

@implementation BLController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabSelectionChanged:) name:@"BLTabSelectionChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAboutView) name:@"BLShowAboutView" object:nil];
    
    [self.tabView selectTabViewItemAtIndex:0];
    
    NSArray *availableFonts = [[NSFontManager sharedFontManager] availableFontFamilies];
    for (NSString *fontFamily in availableFonts) {
        [self.clockFontButton addItemWithTitle:fontFamily];
        [self.dateFontButton addItemWithTitle:fontFamily];
    }
}
- (void)tabSelectionChanged:(NSNotification *)notification {
    NSDictionary *tabDict = notification.userInfo;
    NSInteger selectedIndex = [[tabDict objectForKey:@"selectedTab"] integerValue];
    [self.tabView selectTabViewItemAtIndex:selectedIndex];
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}
- (void)loadDefaults {
    if (!defaults) defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.mtac.betterlogin"];
    
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
    
    if (!containsKey(@"useCustomPlaceholder")) {
        [defaults setObject:@(NO) forKey:@"useCustomPlaceholder"];
    }
    
    if (!containsKey(@"usePhoneBattery")) {
        [defaults setObject:@(NO) forKey:@"usePhoneBattery"];
    }
    
    if (!containsKey(@"hideTextInput")) {
        [defaults setObject:@(NO) forKey:@"hideTextInput"];
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
    if (!containsKey(@"selectedClockFont")) {
        [defaults setObject:@(0) forKey:@"selectedClockFont"];
    }
    if (!containsKey(@"selectedDateFont")) {
        [defaults setObject:@(0) forKey:@"selectedDateFont"];
    }
    
    NSArray *availableFonts = [[NSFontManager sharedFontManager] availableFontFamilies];
    
    if (!containsKey(@"clockFontFamily")) {
        [defaults setObject:availableFonts[0] forKey:@"clockFontFamily"];
    }
    
    if (!containsKey(@"dateFontFamily")) {
        [defaults setObject:availableFonts[0] forKey:@"dateFontFamily"];
    }
    
    [defaults synchronize];
    [self loadPreferences];
}
- (void)loadPreferences {
    self.blurSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"blurEnabled"] boolValue] ?: NO;
    self.clockFontSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"useCustomClockFont"] boolValue] ?: NO;
    self.dateFontSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"useCustomDateFont"] boolValue] ?: NO;
    self.dateFormatSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"useCustomDateFormat"] boolValue] ?: NO;
    self.placeholderSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"hidePasswordPlaceholder"] boolValue] ?: NO;
    self.authHintSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"hidePasswordAuthHints"] boolValue] ?: NO;
    self.customClockFontSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"useCustomClockFontFamily"] boolValue] ?: NO;
    self.customDateFontSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"useCustomDateFontFamily"] boolValue] ?: NO;
    self.customPlaceholderSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"useCustomPlaceholder"] boolValue] ?: NO;
    self.batterySwitch.state = (NSControlStateValue)[[defaults objectForKey:@"usePhoneBattery"] boolValue] ?: NO;
    self.textInputSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"hideTextInput"] boolValue] ?: NO;
    
    NSString *dateFormat = [defaults objectForKey:@"dateFormat"];
    self.dateFormatInput.stringValue = ([dateFormat isEqualToString:@"EEEE, MMMM d"]) ? @"" : dateFormat;
    
    NSString *placeholderString = [defaults objectForKey:@"placeholderString"];
    self.customPlaceholderInput.stringValue = (placeholderString != nil) ? placeholderString : @"";
    
    NSNumber *timeSize = [defaults objectForKey:@"timeSize"];
    self.clockSizeInput.stringValue = ([timeSize integerValue] == 108) ? @"" : [NSString stringWithFormat:@"%ld", [timeSize integerValue]];
    [self.clockSizeStepper setIntegerValue:[timeSize integerValue]];
    
    NSNumber *dateSize = [defaults objectForKey:@"dateSize"];
    self.dateSizeInput.stringValue = ([dateSize integerValue] == 25) ? @"" : [NSString stringWithFormat:@"%ld", [dateSize integerValue]];
    [self.dateSizeStepper setIntegerValue:[dateSize integerValue]];
    
    NSNumber *timePosition = [defaults objectForKey:@"timePosition"];
    self.clockPositionInput.stringValue = ([timePosition integerValue] == 0) ? @"" : [NSString stringWithFormat:@"%ld", [timePosition integerValue]];
    [self.clockPositionStepper setIntegerValue:[timePosition integerValue]];
    
    NSNumber *datePosition = [defaults objectForKey:@"datePosition"];
    self.datePositionInput.stringValue = ([datePosition integerValue] == 0) ? @"" : [NSString stringWithFormat:@"%ld", [datePosition integerValue]];
    [self.datePositionStepper setIntegerValue:[datePosition integerValue]];
    
    NSNumber *selectedBlurStyle = [defaults objectForKey:@"selectedBlurStyle"];
    
    NSMenuItem *selectedBlurItem;
    for (NSMenuItem *item in self.blurStyleButton.itemArray) {
        BOOL selected = (item.tag == [selectedBlurStyle integerValue]);
        item.state = selected ? NSControlStateValueOn : NSControlStateValueOff;
        if (selected) {
            selectedBlurItem = item;
        }
    }
    [self.blurStyleButton selectItem:selectedBlurItem];
    
    [self.clockFontButton selectItemAtIndex:[[defaults objectForKey:@"selectedClockFont"] integerValue]];
    [self.dateFontButton selectItemAtIndex:[[defaults objectForKey:@"selectedDateFont"] integerValue]];
    // [self.blurStyleButton selectItem:[self.blurStyleButton.itemArray objectAtIndex:[[self blurStyles] indexOfObject:selectedBlurStyle]]];
}
- (BOOL)checkNumber:(NSString *)input {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *checkNumber = [numberFormatter numberFromString:input];
    return checkNumber != nil;
}
- (void)showAboutView {
    [self.tabView selectTabViewItemAtIndex:5];
}
- (IBAction)viewSource:(NSButton *)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/MTACS/BetterLogin"]];
}
- (IBAction)selectClockFontIndex:(NSPopUpButton *)sender {
    NSArray *availableFonts = [[NSFontManager sharedFontManager] availableFontFamilies];
    NSInteger selectedIndex = [sender.itemArray indexOfObject:sender.selectedItem];
    [defaults setObject:[NSNumber numberWithInteger:selectedIndex] forKey:@"selectedClockFont"];
    [defaults setObject:[availableFonts objectAtIndex:selectedIndex] forKey:@"clockFontFamily"];
    [defaults synchronize];
}
- (IBAction)selectDateFontIndex:(NSPopUpButton *)sender {
    NSArray *availableFonts = [[NSFontManager sharedFontManager] availableFontFamilies];
    NSInteger selectedIndex = [sender.itemArray indexOfObject:sender.selectedItem];
    [defaults setObject:[NSNumber numberWithInteger:selectedIndex] forKey:@"selectedDateFont"];
    [defaults setObject:[availableFonts objectAtIndex:selectedIndex] forKey:@"dateFontFamily"];
    [defaults synchronize];
}
- (IBAction)blurStyleChanged:(NSPopUpButton *)sender {
    NSMenuItem *selectedItem = sender.selectedItem;
    [defaults setObject:@(selectedItem.tag) forKey:@"selectedBlurStyle"];
    [defaults synchronize];
}
- (IBAction)stepperChanged:(NSStepper *)sender {
    if ([sender isEqual:self.clockSizeStepper]) {
        NSInteger timeSizeValue = sender.integerValue;
        [defaults setObject:@(timeSizeValue) forKey:@"timeSize"];
        self.clockSizeInput.stringValue = [NSString stringWithFormat:@"%ld", timeSizeValue];
    } else if ([sender isEqual:self.clockPositionStepper]) {
        NSInteger clockPositionValue = sender.integerValue;
        [defaults setObject:@(clockPositionValue) forKey:@"timePosition"];
        self.clockPositionInput.stringValue = [NSString stringWithFormat:@"%ld", clockPositionValue];
    } else if ([sender isEqual:self.dateSizeStepper]) {
        NSInteger dateSizeValue = sender.integerValue;
        [defaults setObject:@(dateSizeValue) forKey:@"dateSize"];
        self.dateSizeInput.stringValue = [NSString stringWithFormat:@"%ld", dateSizeValue];
    } else if ([sender isEqual:self.datePositionStepper]) {
        NSInteger datePositionValue = sender.integerValue;
        [defaults setObject:@(datePositionValue) forKey:@"datePosition"];
        self.datePositionInput.stringValue = [NSString stringWithFormat:@"%ld", datePositionValue];
    }
    [defaults synchronize];
}
- (IBAction)authHintsSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"hidePasswordAuthHints"];
    [defaults synchronize];
}
- (IBAction)placeholderSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"hidePasswordPlaceholder"];
    [defaults synchronize];
}
- (IBAction)dateFormatSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"useCustomDateFormat"];
    [defaults synchronize];
}
- (IBAction)customDateFontSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"useCustomDateFontFamily"];
    [defaults synchronize];
}
- (IBAction)dateFontSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"useCustomDateFont"];
    [defaults synchronize];
}
- (IBAction)customClockFontSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"useCustomClockFontFamily"];
    [defaults synchronize];
}
- (IBAction)clockFontSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"useCustomClockFont"];
    [defaults synchronize];
}
- (IBAction)blurSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"blurEnabled"];
    [defaults synchronize];
}
- (IBAction)batterySwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"usePhoneBattery"];
    [defaults synchronize];
}
- (IBAction)inputSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"hideTextInput"];
    [defaults synchronize];
}
- (IBAction)customPlaceholdeSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"useCustomPlaceholder"];
    [defaults synchronize];
}
- (IBAction)placeholderInputChangec:(NSTextField *)sender {
    NSString *customPlaceholderString = sender.stringValue;
    if (customPlaceholderString.length != 0) {
        [defaults setObject:customPlaceholderString forKey:@"placeholderString"];
        [defaults synchronize];
    }
}
- (IBAction)timeSizeChanged:(NSTextField *)sender {
    NSString *clockSizeInput = sender.stringValue;
    if (sender.stringValue.length == 0) {
        [defaults setObject:[NSNumber numberWithInteger:108] forKey:@"timeSize"];
    } else {
        if ([self checkNumber:clockSizeInput]) {
            [defaults setObject:[NSNumber numberWithDouble:[clockSizeInput doubleValue]] forKey:@"timeSize"];
        }
    }
    [defaults synchronize];
}
- (IBAction)timePositionChanged:(NSTextField *)sender {
    NSString *clockPositionInput = sender.stringValue;
    if (sender.stringValue.length == 0) {
        [defaults setObject:[NSNumber numberWithInteger:0] forKey:@"timePosition"];
    } else {
        if ([self checkNumber:clockPositionInput]) {
            [defaults setObject:[NSNumber numberWithInteger:[clockPositionInput integerValue]] forKey:@"timePosition"];
        }
    }
    [defaults synchronize];
}
- (IBAction)dateSizeChanged:(NSTextField *)sender {
    NSString *dateSizeInput = sender.stringValue;
    if (sender.stringValue.length == 0) {
        [defaults setObject:[NSNumber numberWithInteger:25] forKey:@"dateSize"];
    } else {
        if ([self checkNumber:dateSizeInput]) {
            [defaults setObject:[NSNumber numberWithDouble:[dateSizeInput doubleValue]] forKey:@"dateSize"];
        }
    }
    [defaults synchronize];
}
- (IBAction)datePositionChanged:(NSTextField *)sender {
    NSString *datePositionInput = sender.stringValue;
    if (sender.stringValue.length == 0) {
        [defaults setObject:[NSNumber numberWithInteger:0] forKey:@"datePosition"];
    } else {
        if ([self checkNumber:datePositionInput]) {
            [defaults setObject:[NSNumber numberWithInteger:[datePositionInput integerValue]] forKey:@"datePosition"];
        }
    }
    [defaults synchronize];
}
- (IBAction)dateFormatChanged:(NSTextField *)sender {
    if (sender.stringValue.length == 0) {
        [defaults setObject:@"EEEE, MMMM d" forKey:@"dateFormat"];
    } else {
        [defaults setObject:sender.stringValue forKey:@"dateFormat"];
    }
    [defaults synchronize];
}
@end
