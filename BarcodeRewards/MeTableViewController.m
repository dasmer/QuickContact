//
//  MeTableViewController.m
//  QuickContact
//
//  Created by dasmer on 10/29/13.
//  Copyright (c) 2013 Columbia University. All rights reserved.
//

#import "MeTableViewController.h"

@interface MeTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;
@property (weak, nonatomic) IBOutlet UITextField *companyField;
@property (weak, nonatomic) IBOutlet UITextField *departmentField;
@property (weak, nonatomic) IBOutlet UITextField *jobTitleField;



@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobTitleLabel;


@property (strong,nonatomic) NSArray *textfields;
@property (strong,nonatomic) NSArray *labels;
@property (strong,nonatomic) NSArray *saveKeys;








@property (assign, nonatomic) BOOL formWasEdited;
@property (strong,nonatomic) UITapGestureRecognizer *tap;

@end

@implementation MeTableViewController


- (void) awakeFromNib{
    self.title = @"My Information";
    self.tabBarItem.image = [UIImage imageNamed:@"tabMyContactIcon"];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.textfields = @[self.firstNameField, self.lastNameField, self.phoneNumberField, self.emailAddressField,self.companyField,self.departmentField,self.jobTitleField];
    self.labels = @[self.firstNameLabel,self.lastNameLabel,self.phoneNumberLabel,self.emailAddressLabel,self.companyLabel,self.departmentLabel,self.jobTitleLabel];
    self.saveKeys = @[@"fName",@"lName",@"phone",@"email",@"company",@"department",@"jobTitle"];
    
    //self.phoneNumberField.textInputMode = UITExtInput
    
    for (UITextField *textField in self.textfields){
        textField.delegate = self;
    }
    
    self.tap = [[UITapGestureRecognizer alloc]
                initWithTarget:self
                action:@selector(dropKeyboard)];
    [self.tableView addGestureRecognizer:self.tap];
    

   
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *myPreviouslySavedInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"meContact"];;
    if(myPreviouslySavedInfo){
        NSDictionary *myInfoDictionary = [myPreviouslySavedInfo propertyList];
        for (int i=0; i < [self.saveKeys count] ; i++)
        {
            ((UITextField *)self.textfields[i]).text = myInfoDictionary[self.saveKeys[i]];
        }
    }


}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.formWasEdited = NO;

    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    UILabel *label = [self.labels objectAtIndex:[self.textfields indexOfObject:textField]];
    label.textColor = self.tabBarController.tabBar.tintColor;
    return  YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField{
    UILabel *label = [self.labels objectAtIndex:[self.textfields indexOfObject:textField]];
    label.textColor = [UIColor blackColor];
    return  YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.formWasEdited = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= 50 && range.length == 0)
        return NO;
    return YES;
}


- (void) viewWillDisappear:(BOOL)animated{
    
    BOOL formContainsContent = NO;
    
    for(UITextField *textField in self.textfields){
        if ([[self class] isContentInString:textField.text]){
            formContainsContent = YES;
            break;
        }
    }
    if(!formContainsContent){
        [SVProgressHUD showErrorWithStatus:@"Could not generate a new barcode. Please fill in at least one field."];
    }
    else{
    
    if(self.formWasEdited)
    {
        [SVProgressHUD showSuccessWithStatus:@"Your information was saved, and a new barcode was generated."];
        NSMutableDictionary *me = [[NSMutableDictionary alloc] init];
        
        for (int i = 0; i < [self.saveKeys count]; i++)
        {
            NSString *keyText = ((UITextField *)self.textfields[i]).text;
            if ([[self class] isContentInString:keyText])
            {
                [me setObject:keyText forKey:(self.saveKeys[i])];
            }
        }
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[me description] forKey:@"meContact"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    }
    
    [super viewWillDisappear:animated];
}

//- (IBAction)editSaveButton:(id)sender {
//    for (UITextField *textField in self.textfields){
//        textField.enabled = !textField.enabled;
//    }
//    UIButton *button = (UIButton *) sender;
//    if([self.firstNameField isEnabled]){
//        [button setTitle:@"Save" forState:UIControlStateNormal];
//    }
//    else {
//        [button setTitle:@"Edit" forState:UIControlStateNormal];
//      
//    }
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void) dropKeyboard{
    for (UITextField *textfield in self.textfields){
        if([textfield isFirstResponder]){
            [self textFieldShouldReturn:textfield];
            break;
        }
    }
}

+  (BOOL) isContentInString: (NSString *) string{
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([[string stringByTrimmingCharactersInSet: set] length] == 0)
    {
        return NO;
    }
    else{
        return YES;
    }
}


@end
