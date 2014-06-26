//
//  SPKCoreCell.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPKCore.h"

/*
    A cell for showing a core as seen in the basement view of cores
 */
@interface SPKCoreCell : UITableViewCell

@property (nonatomic, strong) SPKCore *core;

@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, assign) NSUInteger index;

@property (weak) IBOutlet UILabel *nameLabel;
@property (weak) IBOutlet UILabel *connectLabel;
@property (weak) IBOutlet UIImageView *grayLineImageView;
@property (weak) IBOutlet UIButton *editButton;
@property (weak) IBOutlet UIButton *expandButton;
@property (weak) IBOutlet UIImageView *spinnerImageView;

- (void)expand;
- (void)contract;
- (void)spinSpinner:(BOOL)go;

@end
