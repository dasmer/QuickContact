//
//  QRViewController.m
//  BarcodeRewards
//
//  Created by dasmer on 10/27/13.
//  Copyright (c) 2013 Columbia University. All rights reserved.
//

#import "QRViewController.h"
#import "qrencode.h"

@interface QRViewController ()

@end

@implementation QRViewController

- (void)awakeFromNib{
    self.title = @"My Barcode";
    self.tabBarItem.image = [UIImage imageNamed:@"tabBarCodeIcon"];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSString *meContact = [[NSUserDefaults standardUserDefaults] objectForKey:@"meContact"];
    
    NSLog(@"count in letters: %lu", (unsigned long)[meContact length]);
    
    NSString *appIdentifier = @"(dastronics)---";
    
    UIImage *image;
    if(meContact){
        NSString *qrString = [appIdentifier stringByAppendingString:meContact];
        image = [self quickResponseImageForString:qrString withDimension:250];
    }
    else{
        image = [UIImage imageNamed:@"placeholder"];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(placeHolderTapped:)];
        [self.imageView addGestureRecognizer:tap];
        self.imageView.userInteractionEnabled = YES;
    }
    
    //set the image
    [self.imageView setImage: image];
}
- (void) placeHolderTapped: (id) sender{
    self.tabBarController.selectedViewController = self.tabBarController.viewControllers[2];
}

void freeRawData(void *info, const void *data, size_t size) {
    free((unsigned char *)data);
}

- (UIImage *)quickResponseImageForString:(NSString *)dataString withDimension:(int)imageWidth {
    
    QRcode *resultCode = QRcode_encodeString([dataString UTF8String], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
    
    unsigned char *pixels = (*resultCode).data;
    int width = (*resultCode).width;
    int len = width * width;
    
    if (imageWidth < width)
        imageWidth = width;
    
    // Set bit-fiddling variables
    int bytesPerPixel = 4;
    int bitsPerPixel = 8 * bytesPerPixel;
    int bytesPerLine = bytesPerPixel * imageWidth;
    int rawDataSize = bytesPerLine * imageWidth;
    
    int pixelPerDot = imageWidth / width;
    int offset = (int)((imageWidth - pixelPerDot * width) / 2);
    
    // Allocate raw image buffer
    unsigned char *rawData = (unsigned char*)malloc(rawDataSize);
    memset(rawData, 0xFF, rawDataSize);
    
    // Fill raw image buffer with image data from QR code matrix
    int i;
    for (i = 0; i < len; i++) {
        char intensity = (pixels[i] & 1) ? 0 : 0xFF;
        
        int y = i / width;
        int x = i - (y * width);
        
        int startX = pixelPerDot * x * bytesPerPixel + (bytesPerPixel * offset);
        int startY = pixelPerDot * y + offset;
        int endX = startX + pixelPerDot * bytesPerPixel;
        int endY = startY + pixelPerDot;
        
        int my;
        for (my = startY; my < endY; my++) {
            int mx;
            for (mx = startX; mx < endX; mx += bytesPerPixel) {
                rawData[bytesPerLine * my + mx    ] = intensity;    //red
                rawData[bytesPerLine * my + mx + 1] = intensity;    //green
                rawData[bytesPerLine * my + mx + 2] = intensity;    //blue
                rawData[bytesPerLine * my + mx + 3] = 255;          //alpha
            }
        }
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, rawData, rawDataSize, (CGDataProviderReleaseDataCallback)&freeRawData);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(imageWidth, imageWidth, 8, bitsPerPixel, bytesPerLine, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    UIImage *quickResponseImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    QRcode_free(resultCode);
    
    return quickResponseImage;
}



@end
