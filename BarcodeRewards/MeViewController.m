//
//  MeViewController.m
//  BarcodeRewards
//
//  Created by dasmer on 10/27/13.
//  Copyright (c) 2013 Columbia University. All rights reserved.
//

#import "MeViewController.h"

@interface MeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *companyField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;
@property (strong,nonatomic) NSArray *textfields;


@end

@implementation MeViewController


- (void) awakeFromNib{
    self.title = @"My Contact Information";
    self.tabBarItem.image = [UIImage imageNamed:@"tabMyContactIcon"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString *myPreviouslySavedInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"meContact"];;
    if(myPreviouslySavedInfo){
        NSDictionary *myInfoDictionary = [myPreviouslySavedInfo propertyList];
        self.firstNameField.text = myInfoDictionary[@"fName"];
        self.lastNameField.text = myInfoDictionary[@"lName"];
        self.companyField.text = myInfoDictionary[@"company"];
        self.phoneNumberField.text = myInfoDictionary[@"phone"];
        self.emailAddressField.text = myInfoDictionary[@"email"];
    }
    
    
    
    self.textfields = @[self.firstNameField, self.lastNameField, self.companyField, self.phoneNumberField, self.emailAddressField];
    for (UITextField *textField in self.textfields){
        textField.delegate = self;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)editSaveButton:(id)sender {
    for (UITextField *textField in self.textfields){
        textField.enabled = !textField.enabled;
    }
    UIButton *button = (UIButton *) sender;
    if([self.firstNameField isEnabled]){
        [button setTitle:@"Save" forState:UIControlStateNormal];
    }
    else {
        [button setTitle:@"Edit" forState:UIControlStateNormal];
        [SVProgressHUD showSuccessWithStatus:@"Your Information was Saved"];
        NSDictionary *me = [[NSDictionary alloc] initWithObjects:@[self.firstNameField.text, self.lastNameField.text, self.companyField.text, self.phoneNumberField.text, self.emailAddressField.text] forKeys:@[@"fName",@"lName",@"company",@"phone",@"email"]];
        [[NSUserDefaults standardUserDefaults] setObject:[me description] forKey:@"meContact"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
