//
//  QRreader.h
//  BarcodeRewards
//
//  Created by dasmer on 10/26/13.
//  Copyright (c) 2013 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface QRreader : NSObject <AVCaptureMetadataOutputObjectsDelegate>{
 
}


- (id) initWithCaptureSession: (AVCaptureSession *) captureSession AndPreviewLayer: (AVCaptureVideoPreviewLayer *) previewLayer AndPreviewView: (UIView *) previewView ForViewController: (UIViewController *) viewController AndScannableRegion: (UIView *) scannableRegion;
- (void) setMetadataObjectTypes;
@end
