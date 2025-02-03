//
//  BLSplitView.m
//  BetterLoginApp
//
//  Created by DF on 1/30/25.
//

#import "BLSplitView.h"

@implementation BLSplitView
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}
- (CGFloat)dividerThickness {
    return 0.5;
}
- (NSColor *)dividerColor {
    return [NSColor separatorColor];
}
@end
