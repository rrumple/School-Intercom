//
//  RequestSchoolViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 11/22/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "RequestSchoolViewController.h"

@interface RequestSchoolViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *yourNameTF;
@property (weak, nonatomic) IBOutlet UITextField *schoolnameTF;
@property (weak, nonatomic) IBOutlet UITextField *cityTF;
@property (weak, nonatomic) IBOutlet UITextField *stateTF;
@property (weak, nonatomic) IBOutlet UITextField *schoolContactTF;
@property (weak, nonatomic) IBOutlet UIButton *addSchoolSendButton;
@property (weak, nonatomic) IBOutlet UITextField *yourEmailTF;
@property (nonatomic) CGFloat animatedDistance;

@property (nonatomic, strong) NSArray *stateNames;
@property (nonatomic, strong) NSArray *stateAbbreviations;
@property (nonatomic) NSInteger stateSelected;

@property (nonatomic, strong) RegistrationModel *registerData;

@end

@implementation RequestSchoolViewController

-(RegistrationModel *)registerData
{
    if(!_registerData) _registerData = [[RegistrationModel alloc]init];
    return _registerData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Flurry logEvent:@"REQUEUST_SCHOOL_SCREEN_VIEWED"];
    
    self.stateTF.inputView = [self createPickerWithTag:zPickerState];

    
    self.stateNames = @[@"Alabama",
                            @"Alaska",
                            @"Arizona",
                            @"Arkansas",
                            @"California",
                            @"Colorado",
                            @"Connecticut",
                            @"Delaware",
                            @"Florida",
                            @"Georgia",
                            @"Hawaii",
                            @"Idaho",
                            @"Illinois",
                            @"Indiana",
                            @"Iowa",
                            @"Kansas",
                            @"Kentucky",
                            @"Louisiana",
                            @"Maine",
                            @"Maryland",
                            @"Massachusetts",
                            @"Michigan",
                            @"Minnesota",
                            @"Mississippi",
                            @"Missouri",
                            @"Montana",
                            @"Nebraska",
                            @"Nevada",
                            @"New Hampshire",
                            @"New Jersey",
                            @"New Mexico",
                            @"New York",
                            @"North Carolina",
                            @"North Dakota",
                            @"Ohio",
                            @"Oklahoma",
                            @"Oregon",
                            @"Pennsylvania",
                            @"Rhode Island",
                            @"South Carolina",
                            @"South Dakota",
                            @"Tennessee",
                            @"Texas",
                            @"Utah",
                            @"Vermont",
                            @"Virginia",
                            @"Washington",
                            @"West Virginia",
                            @"Wisconsin",
                            @"Wyoming",
                            @"Washington, DC"];
    
    self.stateAbbreviations = @[@"AL",
                                    @"AK",
                                    @"AZ",
                                    @"AR",
                                    @"CA",
                                    @"CO",
                                    @"CT",
                                    @"DE",
                                    @"FL",
                                    @"GA",
                                    @"HI",
                                    @"ID",
                                    @"IL",
                                    @"IN",
                                    @"IA",
                                    @"KS",
                                    @"KY",
                                    @"LA",
                                    @"ME",
                                    @"MD",
                                    @"MA",
                                    @"MI",
                                    @"MN",
                                    @"MS",
                                    @"MO",
                                    @"MT",
                                    @"NE",
                                    @"NV",
                                    @"NH",
                                    @"NJ",
                                    @"NM",
                                    @"NY",
                                    @"NC",
                                    @"ND",
                                    @"OH",
                                    @"OK",
                                    @"OR",
                                    @"PA",
                                    @"RI",
                                    @"SC",
                                    @"SD",
                                    @"TN",
                                    @"TX",
                                    @"UT",
                                    @"VT",
                                    @"VA",
                                    @"WA",
                                    @"WV",
                                    @"WI",
                                    @"WY",
                                    @"DC"
                                    ];
    [self setupTapGestures];
    // Do any additional setup after loading the view.
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;
    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    
    
    
    
}

-(UIPickerView *)createPickerWithTag:(NSInteger)tag
{
    UIPickerView *pickerView = [[UIPickerView alloc]init];
    pickerView.tag = tag;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [pickerView setShowsSelectionIndicator:YES];
    
    
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickerViewTapped)];
    
    [tapGR setNumberOfTapsRequired:1];
    [tapGR setDelegate:self];
    [pickerView addGestureRecognizer:tapGR];
    
    return pickerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)checkToSeeIfAButtonShouldBeUnhidden
{
    if([[HelperMethods prepStringForValidation:self.yourNameTF.text] length] > 0 && [[HelperMethods prepStringForValidation:self.schoolnameTF.text] length] > 0 && [[HelperMethods prepStringForValidation:self.cityTF.text] length] > 0 && [self.stateTF.text length] > 0 && [[HelperMethods prepStringForValidation:self.schoolContactTF.text] length] > 0 && [self.yourEmailTF.text length] > 0 && [HelperMethods isEmailValid:self.yourEmailTF.text])
    {
        self.addSchoolSendButton.hidden = NO;
    }
    else
        self.addSchoolSendButton.hidden = YES;
    
}



-(void)hideKeyboard
{
    [self checkToSeeIfAButtonShouldBeUnhidden];
    
    [self.yourEmailTF resignFirstResponder];
    [self.yourNameTF resignFirstResponder];
    [self.schoolnameTF resignFirstResponder];
    [self.cityTF resignFirstResponder];
    [self.stateTF resignFirstResponder];
    [self.schoolnameTF resignFirstResponder];
    [self.schoolContactTF resignFirstResponder];
}



- (IBAction)addSchoolRequestButtonPressed
{
    if ([HelperMethods isEmailValid:self.yourEmailTF.text])
    {
        dispatch_queue_t createQueue = dispatch_queue_create("sendEmail", NULL);
        dispatch_async(createQueue, ^{
            NSArray *emailArray;
            emailArray = [self.registerData sendEmailToRequestSchoolAdditionBy:self.yourNameTF.text emailAddress:self.yourEmailTF.text forSchoolNamed:self.schoolnameTF.text inCity:self.cityTF.text inState:self.stateTF.text withSchoolContactName:self.schoolContactTF.text];
            
            if (emailArray)
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@", [emailArray objectAtIndex:0]);
                    
                    
                    if(![[[emailArray objectAtIndex:0]objectForKey:@"error"] boolValue])
                    {
                        [Flurry logEvent:@"NEW_SCHOOL_REQUESTED"];
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Sent" message:@"Message Sent Successfully" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                        alert.delegate = self;
                        alert.tag = zAlertEmailSent;
                        
                        [alert show];
                        self.yourNameTF.text = @"";
                        self.schoolnameTF.text = @"";
                        self.cityTF.text = @"";
                        self.stateTF.text =@"";
                        self.schoolContactTF.text = @"";
                        self.yourEmailTF.text = @"";
                    
                        
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Sent" message:@"Message Sent Failed! Try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                        
                        [alert show];
                        
                    }
                    
                    
                    
                });
                
            }
        });
    }
    else
    {
        UIAlertView *badEmailAlert = [[UIAlertView alloc]initWithTitle:@"Invalid Email Address" message:@"Please enter a valid email address" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [badEmailAlert show];
    }
    
}

- (void)pickerViewTapped
{
    if(self.stateTF.isFirstResponder)
    {
        //start DB query to load cities
        //[self getCitiesFromDatabase];
        
        [self hideKeyboard];
        
        
    }
}

- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Delegate Section


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    return self.stateNames.count;
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.stateNames objectAtIndex:row];
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.stateTF.text = [self.stateAbbreviations objectAtIndex:row];
    self.stateSelected = row;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertEmailSent)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    
    if(self.stateTF.isFirstResponder)
    {
        if ([self.stateTF.text isEqualToString:@""])
        {
            self.stateTF.text = [self.stateAbbreviations objectAtIndex:0];
        }
    }

    
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if(heightFraction < 0.0){
        
        heightFraction = 0.0;
        
    }else if(heightFraction > 1.0){
        
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        
        self.animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
        
    }else{
        
        self.animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= self.animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += self.animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}





@end
