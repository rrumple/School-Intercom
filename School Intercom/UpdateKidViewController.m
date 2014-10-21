//
//  UpdateKidViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 7/28/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "UpdateKidViewController.h"

@interface UpdateKidViewController ()
@property (nonatomic, strong) UpdateProfileModel *updateProfileData;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTF;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTF;
@property (weak, nonatomic) IBOutlet UITextField *schoolTF;
@property (weak, nonatomic) IBOutlet UITextField *gradeTF;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *addUpdateButton;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (nonatomic) BOOL gradeTFready;
@property (nonatomic) BOOL firstNameTFready;
@property (nonatomic) BOOL lastNameTFready;
@end

@implementation UpdateKidViewController

- (UpdateProfileModel *)updateProfileData
{
    if(!_updateProfileData) _updateProfileData = [[UpdateProfileModel alloc]init];
    return _updateProfileData;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)deleteKidFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("deleteKid", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.updateProfileData deleteKidFromDatabase:[self.kidData objectForKey:ID]];
        if ([dataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                    
                }
                else
                {
                   
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Kid Deleted" message:[NSString stringWithFormat:@"%@ has been removed successfully", self.firstNameTF.text]delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    alert.tag = zAlertDeleteKidSuccess;
                    [alert show];
                    
                }
            });
            
        }
    });
    
}

- (void)updateKidInDatabase
{
    NSString *kidID;
    if(self.addingNewKid)
    {
        kidID = @"999";
    }
    else
    {
        kidID = [self.kidData objectForKey:ID];
    }
        
    
    
    NSDictionary *tempDic = [[NSDictionary alloc]initWithObjects:@[kidID, self.firstNameTF.text, self.lastNameTF.text, self.gradeTF.text, self.mainUserData.schoolIDselected, self.mainUserData.userID ] forKeys:@[KID_ID, KID_FIRST_NAME, KID_LAST_NAME, KID_GRADE_LEVEL, SCHOOL_ID, USER_ID]];
    
    dispatch_queue_t createQueue = dispatch_queue_create("updateKid", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.updateProfileData updateKidFromKidDicData:tempDic];
        if ([dataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                    
                }
                else
                {
                    NSString *stringOne;
                    NSString *stringTwo;
                    
                    if(self.addingNewKid)
                    {
                        stringOne = @"Kid Added";
                        stringTwo = [NSString stringWithFormat:@"%@ has been added successfully.", self.firstNameTF.text];
                        
                    }
                    else
                    {
                        stringOne = @"Kid Updated";
                        stringTwo = [NSString stringWithFormat:@"%@'s information has been updated", self.firstNameTF.text];
                    }
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:stringOne message:stringTwo delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    alert.tag = zAlertKidAddUpdatedSuccess;
                    [alert show];
                    
                }
            });
            
        }
    });
    
}

- (void)checkToSeeIfButtonShouldBeEnabled
{
    NSLog(@"%@", self.firstNameTF.text);
    if(self.firstNameTFready && self.lastNameTFready && self.gradeTFready )
    {
        self.addUpdateButton.enabled = true;
    }
    else
        self.addUpdateButton.enabled = false;

}

-(void)hideKeyboard
{
    [self checkToSeeIfButtonShouldBeEnabled];
    
    [self.firstNameTF resignFirstResponder];
    [self.lastNameTF resignFirstResponder];
    [self.schoolTF resignFirstResponder];
    [self.gradeTF resignFirstResponder];
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;
    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    
    
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTapGestures];
    
    self.firstNameTF.delegate = self;
    self.lastNameTF.delegate = self;
    self.gradeTF.delegate = self;
    self.gradeTFready = NO;
    self.firstNameTFready = NO;
    self.lastNameTFready = NO;
    
    
    if (self.addingNewKid)
    {
        self.deleteButton.enabled = false;
        [self.addUpdateButton setTitle:@"Add" forState:UIControlStateNormal];
        self.schoolTF.text = [self.mainUserData getSchoolNameFromID:self.mainUserData.schoolIDselected];
        self.header.text = @"Add a Kid";
    }
    else
    {
        self.firstNameTF.text = [self.kidData objectForKey:KID_FIRST_NAME];
        self.lastNameTF.text = [self.kidData objectForKey:KID_LAST_NAME];
        self.gradeTF.text = [self.kidData objectForKey:KID_GRADE_LEVEL];
        self.schoolTF.text = [self.mainUserData getSchoolNameFromID:[self.kidData objectForKey:SCHOOL_ID]];
        self.addUpdateButton.enabled = true;
        self.gradeTFready = YES;
        self.firstNameTFready = YES;
        self.lastNameTFready = YES;
    }
}
- (IBAction)deleteButtonPressed
{
    
    UIAlertView *deleteConfrimAlert = [[UIAlertView alloc]initWithTitle:@"Remove Kid" message:[NSString stringWithFormat:@"You are about to remove %@ from your profile, are you sure?", self.firstNameTF.text] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    deleteConfrimAlert.tag = zAlertDeleteKid;
    [deleteConfrimAlert show];
    
   
}

- (IBAction)privacyPolicyButtonPressed
{
    //[self.navigationController popToRootViewControllerAnimated:YES];
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.myschoolintercom.com/privacy.php"]];

}

- (IBAction)addUpdateButtonPressed:(UIButton *)sender
{
    [self updateKidInDatabase];
}

- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *newString = textField.text;
    
    newString = [newString stringByReplacingCharactersInRange:range withString:string];

    
    switch (textField.tag)
    {
        case 1:
        {
            if ([newString length] > 0)
                self.firstNameTFready = YES;
            else
                self.firstNameTFready = NO;
        }
            break;
        case 2:
        {
            if ([newString length] > 0)
                self.lastNameTFready = YES;
            else
                self.lastNameTFready = NO;
        }
            break;
        case 3:
            break;
        case 4:
        {
            if(![newString isEqualToString:@""] && [newString intValue] >= 0 && [newString intValue] <=12)
            {
                textField.textColor = [UIColor blackColor];
                self.gradeTFready = YES;
            }
            else
            {
                self.gradeTFready = NO;
                textField.textColor = [UIColor redColor];
            }

        }
            break;
    }
    
    [self checkToSeeIfButtonShouldBeEnabled];
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case zAlertDeleteKidSuccess:
        case zAlertKidAddUpdatedSuccess:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case zAlertDeleteKid:
        {
            switch (buttonIndex)
            {
                case 0:
                    break;
                case 1:
                     [self deleteKidFromDatabase];
                    break;
            }
        }
            break;
            
    }
    
    
    
}

@end
