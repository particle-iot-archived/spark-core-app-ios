//
//  SPKCoresViewController.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPKCoresViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak) IBOutlet UITableView *tableView;

- (IBAction)expandToggled:(id)sender;
- (IBAction)reflashTinker:(id)sender;
- (IBAction)editName:(id)sender;
- (IBAction)clearTinker:(id)sender;

@end
