//
//  BLSidebarController.m
//  BetterLoginApp
//
//  Created by DF on 1/30/25.
//

#import "BLSidebarController.h"

@interface BLSidebarController ()
@end

@implementation BLSidebarController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.target = self;
    self.tableView.action = @selector(tableViewClicked:);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAboutView) name:@"BLShowAboutView" object:nil];
    
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:YES];
    
    // [self.tableView editColumn:0 row:0 withEvent:nil select:YES];
    
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"BLSidebarCell" bundle:nil] forIdentifier:@"sidebarCell"];
}
- (void)showAboutView {
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:5] byExtendingSelection:NO];
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 6;
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 36.0;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *titles = @[@"Wallpaper", @"Clock", @"Date", @"Password", @"Other", @"About"];
    NSArray *images = @[@"macwindow", @"clock", @"calendar", @"key.horizontal", @"battery", @"info"];
    BLSidebarCell *cell = [tableView makeViewWithIdentifier:@"sidebarCell" owner:self];
    [cell.titleLabel setStringValue:titles[row]];
    [cell.imageView setImage:[NSImage imageNamed:images[row]]];
    return cell;
}
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    BLTableRowView *rowView = [tableView makeViewWithIdentifier:@"tableRowView" owner:self];
    if (!rowView) {
        rowView = [[BLTableRowView alloc] initWithFrame:NSZeroRect];
        rowView.identifier = @"tableRowView";
    }
    return rowView;
}
- (NSImage *)symbolImage:(NSImage *)image {
    NSImage *scaledImage = [[NSImage alloc] initWithSize:CGSizeMake(20, 20)];
    [scaledImage lockFocus];
    [image setSize:CGSizeMake(20, 20)];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [image drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, 20, 20) operation:NSCompositingOperationCopy fraction:1.0];
    [scaledImage unlockFocus];
    return scaledImage;
}
- (void)tableViewClicked:(id)sender {
    NSInteger selectedRow = self.tableView.selectedRow;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLTabSelectionChanged" object:nil userInfo:@{@"selectedTab" : [NSNumber numberWithInteger:selectedRow]}];
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
     NSInteger selectedRow = [self.tableView selectedRow];
     BLTableRowView *myRowView = [self.tableView rowViewAtRow:selectedRow makeIfNecessary:NO];
     [myRowView setEmphasized:YES];
}
@end
