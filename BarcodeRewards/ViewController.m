//
//  ViewController.m
//  BarcodeRewards
//
//  Created by dasmer on 10/26/13.
//  Copyright (c) 2013 Columbia University. All rights reserved.
//

#import "ViewController.h"
#import "Camera.h"


@interface ViewController ()
@property (strong,nonatomic) Camera *camera;



@end

@implementation ViewController{
    BOOL didFindBarcode;
    __weak IBOutlet UIView *_previewView;
    __weak IBOutlet UIImageView *_scannableRegion;
}


- (void) awakeFromNib {
    self.title = @"Scan Barcode";
    self.tabBarItem.image = [UIImage imageNamed:@"tabCameraIcon"];


}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.camera = [[Camera alloc] initWithPreviewView:_previewView ForViewController:self AndScannableRegion:_scannableRegion];
    
    _scannableRegion.image = [UIImage imageNamed:@"tracemark.png"];
    
	// Do any additional setup after loading the view, typically from a nib.    
}


//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self.camera startRunning];
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.camera startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.camera stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) foundBarcodeWithString: (NSString *) barcodeString{
    
    NSString *appIdentifier = @"(dastronics)---";
    
    
       dispatch_async(dispatch_get_main_queue(), ^{
           
           if([barcodeString rangeOfString:appIdentifier].location == NSNotFound)
           {
               [SVProgressHUD showErrorWithStatus:@"Invalid Barcode"];
           }
           else
           {
            NSString *filteredString = [barcodeString componentsSeparatedByString:@"ics)---"][1];
           NSLog(@"vc found bc %@",barcodeString);
           [self.camera stopRunning];
           double delayInSeconds = 0.0;
           dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
               NSLog(@"TEST:  %@", filteredString);
           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
               
               [self startContactsModalWithDictionary:[filteredString propertyList]];
           });
           
            }
       });
    

}


- (void) startContactsModalWithDictionary: (NSDictionary *)
contact{
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
    
    [picker setNewPersonViewDelegate:self];
    

    
    NSString *firstName = contact[@"fName"];
    NSString *lastName = contact[@"lName"];
    NSString *phone = contact[@"phone"];
    NSString *email = contact[@"email"];
    NSString *company = contact[@"company"];
    NSString *department = contact[@"department"];
    NSString *jobTitle = contact[@"jobTitle"];
    


    ABRecordRef newPerson = ABPersonCreate();
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (CFStringRef)CFBridgingRetain(firstName), nil);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, (CFStringRef)CFBridgingRetain(lastName), nil);

//    ABRecordSetValue(newPerson, kABPersonPhoneProperty, (CFStringRef)CFBridgingRetain(phone), nil);
//    ABRecordSetValue(newPerson, kABPersonEmailProperty, (CFStringRef)CFBridgingRetain(email), nil);

    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    ABMultiValueAddValueAndLabel(multiPhone,(CFStringRef)CFBridgingRetain(phone), kABWorkLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
    CFRelease(multiPhone);
    
    
    
    
    
    ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);

    ABMultiValueAddValueAndLabel(multiEmail, (CFStringRef)CFBridgingRetain(email), kABWorkLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, nil);
    
    CFRelease(multiEmail);
    
    ABRecordSetValue(newPerson, kABPersonOrganizationProperty, (CFStringRef)CFBridgingRetain(company), nil);
    ABRecordSetValue(newPerson, kABPersonDepartmentProperty, (CFStringRef)CFBridgingRetain(department), nil);
    ABRecordSetValue(newPerson, kABPersonJobTitleProperty, (CFStringRef)CFBridgingRetain(jobTitle), nil);

    
    
    picker.displayedPerson = newPerson;
    
    
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:picker];
    
    [self presentViewController:navC animated:YES completion:NULL];
 

}
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person{
    [newPersonView.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
