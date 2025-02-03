//
//  BLSidebarController.h
//  BetterLoginApp
//
//  Created by DF on 1/30/25.
//

#import <Cocoa/Cocoa.h>
#import "../Classes/BLSidebarCell.h"
#import "../Classes/BLTableRowView.h"

@interface BLSidebarController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>
@property (strong) IBOutlet NSTableView *tableView;
@end
