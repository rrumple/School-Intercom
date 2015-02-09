//
//  ContactViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "ContactViewController.h"
#import "MainNavigationController.h"
#import "MainMenuViewController.h"

@interface ContactViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (nonatomic, strong) ContactModel *contactData;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (nonatomic, strong) NSMutableArray *toNames;
@property (weak, nonatomic) IBOutlet UILabel *schoolNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *zipCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *overlay1;
@property (weak, nonatomic) IBOutlet UIView *helpOverlay;
@property (weak, nonatomic) IBOutlet UITextField *toTextfield;
@property (nonatomic, strong) NSString *toUserID;

@end

@implementation ContactViewController
//static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
//static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
//static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
//static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
//static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

- (NSMutableArray *)toNames
{
    if(!_toNames) _toNames = [[NSMutableArray alloc]init];
    return _toNames;
}

- (ContactModel *)contactData
{
    if(!_contactData) _contactData = [[ContactModel alloc]init];
    return _contactData;
}

- (void)pickerViewTapped
{
    if(self.toTextfield.isFirstResponder)
    {
        
        [self hideKeyboard];
        
    }
    
    
}

-(UIPickerView *)createPickerWithTag:(NSInteger)tag
{
    UIPickerView *pickerView = [[UIPickerView alloc]init];
    pickerView.tag = tag;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    
    
    
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickerViewTapped)];
    //tapGR.cancelsTouchesInView = NO;
    
    [tapGR setNumberOfTapsRequired:1];
    
    [tapGR setDelegate:self];
    [pickerView addGestureRecognizer:tapGR];
    
    return pickerView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.toUserID = @"";
    self.toNames = [self.mainUserData.teacherNames mutableCopy];
    [self.toNames addObject:@{@"teacherName":@"Submit Bugs/Feedback",@"id":@"374825e5c3d74cca7e85cbc23e61bc90"}];
    NSLog(@"%@", self.toNames);
    NSMutableArray *itemsToRemove = [[NSMutableArray alloc]init];
    for (NSDictionary *tempDic in self.toNames)
    {
        if([[tempDic objectForKey:ID]isEqualToString:self.mainUserData.userID] || ![[tempDic objectForKey:SCHOOL_ID]isEqualToString:self.mainUserData.schoolIDselected])
            if(![[tempDic objectForKey:@"teacherName"]isEqualToString:@"Submit Bugs/Feedback"])
                [itemsToRemove addObject:tempDic];
    }
    
    [self.toNames removeObjectsInArray:itemsToRemove];
    
      NSLog(@"%@", self.toNames);
        
    
    [self setupTapGestures];
    
    [self.bodyTextView.layer setCornerRadius:15.0f];
    [self.bodyTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.bodyTextView.layer setBorderWidth:1.5f];
    [self.bodyTextView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.bodyTextView.layer setShadowOpacity:0.8];
    [self.bodyTextView.layer setShadowRadius:3.0];
    [self.bodyTextView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    self.bodyTextView.delegate = self;
    
    self.schoolNameLabel.text = [self.schoolData objectForKey:SCHOOL_NAME];
    self.cityLabel.text = [NSString stringWithFormat:@"%@, %@ %@", [self.schoolData objectForKey:SCHOOL_CITY], [self.schoolData objectForKey:SCHOOL_STATE], [self.schoolData objectForKey:SCHOOL_ZIP]];

    self.phoneNumberLabel.text = [self.schoolData objectForKey:SCHOOL_PHONE];
    
    self.toTextfield.inputView = [self createPickerWithTag:zPickerName];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.headerLabel setFont:FONT_CHARCOAL_CY(17.0f)];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([self.mainUserData getTutorialStatusOfView:mv_Contact])
        [self showHelp];
}

- (void)showHelp
{
    self.helpOverlay.hidden = false;
    self.overlay1.hidden = false;
    
    [UIView animateWithDuration:1 animations:^{
        
        
        self.overlay1.alpha = 0.5;
        self.helpOverlay.alpha = 1.0;
        //self.dismissButton.alpha = 1.0;
        //self.help1.alpha = 1.0;
    }];
}

- (IBAction)hideHelpPressed
{
    [self.mainUserData turnOffTutorialForView:mv_Contact];
    [UIView animateWithDuration:.75 animations:^{
        self.overlay1.alpha = 0.0;
        self.helpOverlay.alpha = 0.0;
        //self.dismissButton.alpha = 1.0;
        //self.help1.alpha = 1.0;
        
    }completion:^(BOOL finished){
        self.overlay1.hidden = true;
        self.helpOverlay.hidden = true;
    }];
    
    
    
    
    
}


-(void)hideKeyboard
{
    //[self checkToSeeIfAButtonShouldBeUnhidden];
    
    [self.subjectTextField resignFirstResponder];
    [self.bodyTextView resignFirstResponder];
    [self.toTextfield resignFirstResponder];
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = YES;
    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)menuPressed
{
    if([self.delegate respondsToSelector:@selector(snapshotOfViewAsImage:)])
    {
        [self.delegate snapshotOfViewAsImage:[UIView captureView:self.view]];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)clearButtonPressed
{
    
    self.subjectTextField.text = nil;
    self.bodyTextView.text = nil;
}

- (void)sendEmail
{
    dispatch_queue_t createQueue = dispatch_queue_create("sendEmail", NULL);
    dispatch_async(createQueue, ^{
        NSArray *emailArray;
        emailArray = [self.contactData sendEmailTo:self.toUserID withSchoolID:[self.schoolData objectForKey:ID] withSubject:self.subjectTextField.text andMessage:self.bodyTextView.text fromUser:self.mainUserData.userID];
        
        if (emailArray)
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@", [emailArray objectAtIndex:0]);
                
                
                if(![[[emailArray objectAtIndex:0]objectForKey:@"error"] boolValue])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Sent" message:@"Message Sent Successfully" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                    
                    [alert show];
                    [self clearButtonPressed];
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

- (IBAction)sendButtonPressed
{
    if(self.subjectTextField.hasText && self.bodyTextView.hasText)
       [self sendEmail];
    else
    {
        UIAlertView *missingTextAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"The subject and comment seciton must not be blank" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [missingTextAlert show];
    }
}

-(void) textViewDidBeginEditing:(UITextView *)textView {
    
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
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

- (void)textViewDidEndEditing:(UITextView *)textView{
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += self.animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.toNames count];
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerName)
    {
        
        return [[self.toNames
                 objectAtIndex:row] objectForKeyedSubscript:@"teacherName"];
        
    }
    
    return @"";
}




-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerName)
    {
        self.toTextfield.text =  [[self.toNames objectAtIndex:row]objectForKey:@"teacherName"];
        self.toUserID = [[self.toNames objectAtIndex:row]objectForKey:ID];
        
    }
    
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.toTextfield.isFirstResponder)
    {
        if ([self.toTextfield.text isEqualToString:@""])
        {
            self.toTextfield.text =  [[self.toNames objectAtIndex:0]objectForKey:@"teacherName"];
            self.toUserID = [[self.toNames objectAtIndex:0]objectForKey:ID];
            
          
            
        }
    }
    
}


@end
