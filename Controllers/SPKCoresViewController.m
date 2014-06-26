//
//  SPKCoresViewController.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKCoresViewController.h"
#import "SPKCoreCell.h"
#import "SPKSpark.h"

@interface SPKCoresViewController ()

@property (nonatomic, strong) NSMutableIndexSet *expandedIndexSet;
@property (nonatomic, strong) SPKCoreCell *cellForNaming;

@end

@implementation SPKCoresViewController

- (void)awakeFromNib
{
    self.expandedIndexSet = [NSMutableIndexSet indexSet];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)expandToggled:(id)sender
{
    [self.tableView beginUpdates];

    SPKCoreCell *cell = (SPKCoreCell *)[[[(UIButton *)sender superview] superview] superview];
    cell.expanded = !cell.expanded;
    if (cell.expanded) {
        [self.expandedIndexSet addIndex:cell.index];
        [cell expand];
    } else {
        [cell contract];
        [self.expandedIndexSet removeIndex:cell.index];
    }
    [self.tableView endUpdates];
}

- (IBAction)reflashTinker:(id)sender
{
    SPKCoreCell *cell = (SPKCoreCell *)[[[(UIButton *)sender superview] superview] superview];
    SPKCore *core = cell.core;

    [cell spinSpinner:YES];

    [[SPKSpark sharedInstance].webClient flashTinker:core.coreId success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell spinSpinner:NO];
            [[[UIAlertView alloc] initWithTitle:@"Tinker" message:@"Core is being re-flashed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        });
    } failure:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell spinSpinner:NO];
            [[[UIAlertView alloc] initWithTitle:@"Tinker" message:@"Problem re-flashing Core" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        });
    }];
}

- (IBAction)editName:(id)sender
{
    self.cellForNaming = (SPKCoreCell *)[[[(UIButton *)sender superview] superview] superview];

    UIAlertView *alertView = [[UIAlertView alloc] init];
    [alertView setDelegate:self];
    alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alertView setTitle:@"Rename Core"];
    [alertView setMessage:@"Enter new Core name"];

    [alertView addButtonWithTitle:@"Cancel"];
    [alertView addButtonWithTitle:@"Ok"];


    UITextField *nameTextField  = [alertView textFieldAtIndex:0];
    nameTextField.placeholder = self.cellForNaming.core.name;
    nameTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [alertView show];
}

- (IBAction)clearTinker:(id)sender
{
    SPKCore *core = [SPKSpark sharedInstance].activeCore;
    [core reset];
    [self performSegueWithIdentifier:@"tinker" sender:sender];
}

#pragma mark - AlertView DataSource

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) { // Ok
        NSString *name = [[alertView textFieldAtIndex:0] text];
        self.cellForNaming.core.name = name;
        self.cellForNaming.nameLabel.text = name;
        [[SPKSpark sharedInstance].webClient name:self.cellForNaming.core.coreId label:name success:^{
            // do nothing
        } failure:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Rename Core" message:@"There was a problem renaming the Core" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            });
        }];
    }
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [SPKSpark sharedInstance].cores.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPKCoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"core"];
    cell.core = [SPKSpark sharedInstance].cores[indexPath.row];
    cell.index = indexPath.row;
    if (cell.expanded) {
        [cell expand];
    } else {
        [cell contract];
    }

    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPKCoreCell *cell = (SPKCoreCell *)[tableView cellForRowAtIndexPath:indexPath];
    SPKCore *core = cell.core;

    [[SPKSpark sharedInstance] activateCore:core];
    [self performSegueWithIdentifier:@"tinker" sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.expandedIndexSet containsIndex:indexPath.row]) {
        return 145.0;
    } else {
        return 42;
    }
}

@end
