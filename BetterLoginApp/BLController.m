//
//  BLController.m
//  BetterLoginApp
//
//  Created by MTAC on 8/2/23.
//

#import "BLController.h"

NSUserDefaults *defaults;

@implementation BLController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadPreferences];
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}
- (void)loadPreferences {
    if (!defaults) defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.mtac.betterlogin"];
    self.enableSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"enabled"] boolValue] ?: YES;
    self.blurSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"blurEnabled"] boolValue] ?: NO;
    self.internetSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"internetEnabled"] boolValue] ?: NO;
    self.percentageSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"percentageEnabled"] boolValue] ?: NO;
    self.colorsSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"colorsEnabled"] boolValue] ?: NO;
    self.nameSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"nameEnabled"] boolValue] ?: NO;
    self.pictureSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"pictureEnabled"] boolValue] ?: NO;
    self.placeholderSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"placeholderEnabled"] boolValue] ?: NO;
    self.hintSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"hintsEnabled"] boolValue] ?: NO;
    self.cancelButtonSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"cancelTitleEnabled"] boolValue] ?: NO;
    
    self.nameLabel.enabled = [[defaults objectForKey:@"nameEnabled"] boolValue];
    self.nameLabel.delegate = self;
    NSString *accountName = [defaults objectForKey:@"accountName"];
    if (accountName != nil || ![accountName isEqualToString:@""]) {
        self.nameLabel.stringValue = accountName ?: @"";
    }
}
- (IBAction)enableChanged:(NSSwitch *)sender {
    [defaults setObject:[NSNumber numberWithBool:sender.state] forKey:@"enabled"];
    [defaults synchronize];
}
- (IBAction)blurChanged:(NSSwitch *)sender {
    [defaults setObject:[NSNumber numberWithBool:sender.state] forKey:@"blurEnabled"];
    [defaults synchronize];
}
- (IBAction)internetChanged:(NSSwitch *)sender {
    [defaults setObject:[NSNumber numberWithBool:sender.state] forKey:@"internetEnabled"];
    [defaults synchronize];
}
- (IBAction)percentageChanged:(NSSwitch *)sender {
    [defaults setObject:[NSNumber numberWithBool:sender.state] forKey:@"percentageEnabled"];
    [defaults synchronize];
}
- (IBAction)colorsChanged:(NSSwitch *)sender {
    [defaults setObject:[NSNumber numberWithBool:sender.state] forKey:@"colorsEnabled"];
    [defaults synchronize];
}
- (IBAction)pictureChanged:(NSSwitch *)sender {
    [defaults setObject:[NSNumber numberWithBool:sender.state] forKey:@"pictureEnabled"];
    [defaults synchronize];
}
- (IBAction)placeholderChanged:(NSSwitch *)sender {
    [defaults setObject:[NSNumber numberWithBool:sender.state] forKey:@"placeholderEnabled"];
    [defaults synchronize];
}
- (IBAction)nameChanged:(NSSwitch *)sender {
    [defaults setObject:[NSNumber numberWithBool:sender.state] forKey:@"nameEnabled"];
    [defaults synchronize];
    self.nameLabel.enabled = [[defaults objectForKey:@"nameEnabled"] boolValue];
}
- (IBAction)hintsChanged:(NSSwitch *)sender {
    [defaults setObject:[NSNumber numberWithBool:sender.state] forKey:@"hintsEnabled"];
    [defaults synchronize];
}
- (IBAction)cancelTitleChanged:(NSSwitch *)sender {
    [defaults setObject:[NSNumber numberWithBool:sender.state] forKey:@"cancelTitleEnabled"];
    [defaults synchronize];
}
- (IBAction)apply:(id)sender {
    NSTask *lockTask = [[NSTask alloc] init];
    [lockTask setLaunchPath:@"/usr/bin/pmset"];
    [lockTask setArguments:@[@"sleepnow"]];
    [lockTask launch];
}
- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    if (textField.stringValue != nil || ![textField.stringValue isEqualToString:@""]) {
        [defaults setObject:textField.stringValue forKey:@"accountName"];
        [defaults synchronize];
    }
}
@end
