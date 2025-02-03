//
//  BLSidebarCell.m
//  BetterLoginApp
//
//  Created by DF on 1/30/25.
//

#import "BLSidebarCell.h"

@implementation BLSidebarCell
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    self.imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
}
@end
