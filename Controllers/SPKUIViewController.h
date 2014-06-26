//
//  SPKUIViewController.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
   A base class for some of the other view controllers - mainly the user/login/account
   related ones.
 */
@interface SPKUIViewController : UIViewController

- (CGFloat)keyboardHeightAdjust;
- (void)dismissKeyboard;
- (void)setViewMovedUp:(BOOL)movedUp;
- (BOOL)isValidEmail:(NSString *)checkString;

@end
