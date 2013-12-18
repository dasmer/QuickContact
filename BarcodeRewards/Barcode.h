//
//  Barcode.h
//  BarcodeRewards
//
//  Created by dasmer on 10/26/13.
//  Copyright (c) 2013 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface Barcode : NSObject

@property (nonatomic, strong) AVMetadataMachineReadableCodeObject *metadataObject;
@property (nonatomic, strong) UIBezierPath *cornersPath;
@property (nonatomic, strong) UIBezierPath *boundingBoxPath;


@end
