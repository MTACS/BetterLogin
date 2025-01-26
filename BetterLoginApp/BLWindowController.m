//
//  BLWindowController.m
//  BetterLoginApp
//
//  Created by MTAC on 8/2/23.
//

#import "BLWindowController.h"

@interface BLWindowController ()
@end

@implementation BLWindowController
- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:nil];
    }
    return self;
}
- (void)objectDidBecomeKey:(NSNotification *)notification {
    [self removeBackground:[notification object]];
}
- (void)windowDidLoad {
    [super windowDidLoad];
    [self removeBackground:self.window];
}
- (void)removeBackground:(NSWindow *)window {
    [window setBackgroundColor:[NSColor clearColor]];
    // [window setTitlebarAppearsTransparent:NO];
    // [window setToolbarStyle:NSWindowToolbarStyleUnified];
            
    NSVisualEffectView *effectView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, window.contentView.bounds.size.width, window.contentView.bounds.size.height + 30)];
    [effectView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [effectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [effectView setState:NSVisualEffectStateActive];
    [[window contentView] addSubview:effectView positioned:NSWindowBelow relativeTo:nil];

    [window.contentView setWantsLayer:YES];
    window.contentView.layer.backgroundColor = [NSColor clearColor].CGColor;
}
@end
