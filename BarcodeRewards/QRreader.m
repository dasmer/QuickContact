//
//  QRreader.m
//  BarcodeRewards
//
//  Created by dasmer on 10/26/13.
//  Copyright (c) 2013 Columbia University. All rights reserved.
//

#import "QRreader.h"
#import "Barcode.h"
#import "ViewController.h"


@implementation QRreader{
    AVCaptureMetadataOutput *_metadataOutput;
    NSMutableDictionary *_barcodes;
    __weak AVCaptureVideoPreviewLayer *_previewLayer;
    __weak UIView *_previewView;
    __weak ViewController *_cameraViewController;
    __weak UIView *_scannableRegion;
}

- (id) initWithCaptureSession: (AVCaptureSession *) captureSession AndPreviewLayer: (AVCaptureVideoPreviewLayer *) previewLayer AndPreviewView: (UIView *) previewView ForViewController: (UIViewController *) viewController AndScannableRegion: (UIView *) scannableRegion {
    self = [super init];
    if (self)
    {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        _scannableRegion = scannableRegion;
        _previewLayer = previewLayer;
        _previewView = previewView;
        if ([viewController isKindOfClass:[ViewController class]]) _cameraViewController = (ViewController *) viewController;
        dispatch_queue_t metadataQueue = dispatch_queue_create("com.razeware.ColloQR.metadata", 0);
  
        [_metadataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
        if ([captureSession canAddOutput:_metadataOutput]) {
            [captureSession addOutput:_metadataOutput];
        }
        
        
        _barcodes = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

- (void) setMetadataObjectTypes{
    NSLog(@"scannable region %@ and previewLaye %@" , [_scannableRegion description], [_previewLayer description]);
    
    _metadataOutput.rectOfInterest = [_previewLayer metadataOutputRectOfInterestForRect:_scannableRegion.frame];
    _metadataOutput.metadataObjectTypes = _metadataOutput.availableMetadataObjectTypes;
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    NSMutableSet *foundBarcodes = [[NSMutableSet alloc] init];
    [metadataObjects enumerateObjectsUsingBlock: ^(AVMetadataObject *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"Metadata: %@", obj);
        if ([obj isKindOfClass:
             [AVMetadataMachineReadableCodeObject class]]){
            AVMetadataMachineReadableCodeObject *code =  (AVMetadataMachineReadableCodeObject*) [_previewLayer transformedMetadataObjectForMetadataObject:obj];
            
            Barcode *barcode = [self processMetadataObject:code];
            [foundBarcodes addObject:barcode];
            NSLog(@"found objects count, %d", [foundBarcodes count]);
            [_cameraViewController foundBarcodeWithString:barcode.metadataObject.stringValue];
        }
    }];
    

    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSArray *allSublayers = [_previewView.layer.sublayers copy];
        [allSublayers enumerateObjectsUsingBlock:
         ^(CALayer *layer, NSUInteger idx, BOOL *stop) {
             if (layer != _previewLayer) {
                 [layer removeFromSuperlayer]; }
         }];

        [foundBarcodes enumerateObjectsUsingBlock:^(Barcode *barcode, BOOL *stop) {
            

            CAShapeLayer *boundingBoxLayer = [[CAShapeLayer alloc] init];
            boundingBoxLayer.path = barcode.boundingBoxPath.CGPath; boundingBoxLayer.lineWidth = 2.0f;
            boundingBoxLayer.strokeColor = [[UIColor greenColor] CGColor];
            boundingBoxLayer.fillColor = [[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.5f] CGColor];
            
            [_previewView.layer addSublayer:boundingBoxLayer];
            
            
            CAShapeLayer *cornersPathLayer = [[CAShapeLayer alloc] init];
            
            cornersPathLayer.path = barcode.cornersPath.CGPath;
            
            cornersPathLayer.lineWidth = 2.0f;
            
            cornersPathLayer.strokeColor = [UIColor blueColor].CGColor;
            
            cornersPathLayer.fillColor =
            [[UIColor colorWithRed:0.0f green:0.0f blue:1.0f
                            alpha:0.5f] CGColor];
            
            [_previewView.layer addSublayer:cornersPathLayer];
            
        }];
    });
}

- (Barcode*)processMetadataObject: (AVMetadataMachineReadableCodeObject*)code
{

    Barcode *barcode = _barcodes[code.stringValue];
    if (!barcode) {
        barcode = [[Barcode alloc] init];
        _barcodes[code.stringValue] = barcode;
    }
    
    barcode.metadataObject = code;
    CGMutablePathRef cornersPath = CGPathCreateMutable();
    
    CGPoint point;
    
    CGPointMakeWithDictionaryRepresentation(
                                           (CFDictionaryRef)code.corners[0], &point);

    CGPathMoveToPoint(cornersPath, nil, point.x, point.y);
    
    for (int i = 1; i < code.corners.count; i++){
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[i], &point);
        CGPathAddLineToPoint(cornersPath, nil, point.x, point.y);
    }
    
    CGPathCloseSubpath(cornersPath);
    
    barcode.cornersPath = [UIBezierPath bezierPathWithCGPath:cornersPath];
    CGPathRelease(cornersPath);
    
    barcode.boundingBoxPath =
    [UIBezierPath bezierPathWithRect:code.bounds];
    
    return barcode;
    
}


@end
