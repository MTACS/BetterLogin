//
//  BLWindow.m
//  BetterLoginApp
//
//  Created by DF on 1/30/25.
//

#import "BLWindow.h"

@implementation BLWindow
@synthesize effectView;
- (void)becomeKeyWindow {
    [super becomeKeyWindow];
    [self updateTransparency];
}
- (void)updateTransparency {
    if (!effectView) {
        effectView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height + 30)];
        [effectView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [effectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        [[self contentView] addSubview:effectView positioned:NSWindowBelow relativeTo:nil];
        [self.contentView setWantsLayer:YES];
    }
    [effectView setState:NSVisualEffectStateActive];
}
@end
