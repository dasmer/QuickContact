//
//  ViewController.h
//  BarcodeRewards
//
//  Created by dasmer on 10/26/13.
//  Copyright (c) 2013 Columbia University. All rights reserved.
//


#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <ABNewPersonViewControllerDelegate>


- (void) foundBarcodeWithString: (NSString *) barcodeString;

@end
