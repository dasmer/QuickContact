//
//  Camera.h
//  BarcodeRewards
//
//  Created by dasmer on 10/26/13.
//  Copyright (c) 2013 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Camera : NSObject

- (id) initWithPreviewView: (UIView *) previewView ForViewController: (UIViewController *) viewController AndScannableRegion: (UIView *) scannableRegion;
- (void) startRunning;
- (void)stopRunning;

@end
