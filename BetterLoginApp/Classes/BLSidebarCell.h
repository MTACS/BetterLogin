//
//  BLSidebarCell.h
//  BetterLoginApp
//
//  Created by DF on 1/30/25.
//

#import <Cocoa/Cocoa.h>

@interface BLSidebarCell : NSTableCellView
@property (nonatomic, strong) IBOutlet NSTextField *titleLabel;
@property (nonatomic, strong) IBOutlet NSImageView *iconView;
@end
