//
//  UpdateKidViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 7/28/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "UpdateKidViewController.h"
#import "IntroModel.h"


@interface UpdateKidViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *teacherTableView;
@property (nonatomic, strong) UpdateProfileModel *updateProfileData;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTF;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTF;
@property (weak, nonatomic) IBOutlet UITextField *schoolTF;
@property (weak, nonatomic) IBOutlet UITextField *gradeTF;
@property (nonatomic, strong) IntroModel *introData;
@property (weak, nonatomic) IBOutlet UIButton *addUpdateButton;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (nonatomic) BOOL gradeTFready;
@property (nonatomic) BOOL firstNameTFready;
@property (nonatomic) BOOL lastNameTFready;

@property (nonatomic, strong) NSArray *masterListOfTeachers;
@property (nonatomic, strong) NSDictionary *masterListOfClasses;
@property (nonatomic, strong) NSArray *kidTeachers;

@property (nonatomic, strong) NSArray *teachers;
@property (nonatomic, strong) NSDictionary *teacherData;
@property (nonatomic, strong) NSString *teacherSelected;
@property (nonatomic) NSInteger teacherSelectedRow;
@property (nonatomic, strong) NSString *classSelected;
@property (weak, nonatomic) IBOutlet UIButton *showAddTeacherButton;
@property (weak, nonatomic) IBOutlet UILabel *swipeLabel;
@property (nonatomic) NSInteger rowSelected;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *removeButtonConstraint;
@property (nonatomic, strong) NSLayoutConstraint *origianalConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *hiddenConstraint;
@property (nonatomic, strong) NSArray *tableConstraints;
@property (nonatomic, strong) NSArray *labelConstraints;
@property (nonatomic) BOOL changesMade;
@property (nonatomic) BOOL teacherAdded;
@property (weak, nonatomic) IBOutlet UIView *overlay1;
@property (weak, nonatomic) IBOutlet UIView *helpOverlay;
@end

@implementation UpdateKidViewController

- (IntroModel *)introData
{
    if (!_introData) _introData = [[IntroModel alloc]init];
    return _introData;
}

- (UpdateProfileModel *)updateProfileData
{
    if(!_updateProfileData) _updateProfileData = [[UpdateProfileModel alloc]init];
    return _updateProfileData;
}

- (void)setKidData:(NSDictionary *)kidData
{
    _kidData = kidData;
    if(!self.addingNewKid)
        [self getKidsTeachersFromDatabase];
    //else
        //[self getTeachersFromDatabase];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)filterTeachers
{
    NSMutableArray *tempTeacherArray = [self.masterListOfTeachers mutableCopy];
    NSMutableDictionary *tempDataDic = [self.masterListOfClasses mutableCopy];
    
    if(!tempTeacherArray)
        tempTeacherArray = [[NSMutableArray alloc]init];
    if(!tempDataDic)
        tempDataDic = [[NSMutableDictionary alloc]init];
    
    if([self.masterListOfTeachers count] > 0 && [self.kidTeachers count] > 0)
    {
        for(NSDictionary *teacher in self.masterListOfTeachers)
        {
            
            NSMutableArray *tempClasses = [[self.masterListOfClasses objectForKey:[teacher objectForKey:ID]]mutableCopy];
            NSArray *classes = [self.masterListOfClasses objectForKey:[teacher objectForKey:ID]];
            
            for(NSDictionary *otherTeacher in self.kidTeachers)
            {
                
                for(NSDictionary *class in classes)
                {
                    
                    if([[class objectForKey:ID] isEqualToString:[otherTeacher objectForKey:@"classID"]])
                    {
                        //NSLog(@"test");
                        [tempClasses removeObject:class];
                        
                    }
                }
            }
            
            
            if([tempClasses count] == 0)
            {
                [tempTeacherArray removeObject:teacher];
                [tempDataDic removeObjectForKey:[teacher objectForKey:ID]];
            }
            else
            {
                [tempDataDic setObject:tempClasses forKey:[teacher objectForKey:ID]];
            }
            
        }
    }
    
    if([tempTeacherArray count] == 0)
        [tempTeacherArray addObject:@{TEACHER_PREFIX:@"No Teachers ", TEACHER_LAST_NAME:@"to Display", ID:@"999"}];
    
        
    
    self.teachers = tempTeacherArray;
    self.teacherData = tempDataDic;
  
    UIPickerView *tempPicker = (UIPickerView *)[self.gradeTF.inputView viewWithTag:zPickerTeacher];
    //self.gradeTF.inputView = [self createPickerWithTag:zPickerTeacher];
    [tempPicker reloadAllComponents];

}

- (void)getTeachersFromDatabase
{
    NSString *schoolID;
    if([self.kidData objectForKey:SCHOOL_ID])
        schoolID = [self.kidData objectForKey:SCHOOL_ID];
    else
        schoolID = self.mainUserData.schoolIDselected;
        
    dispatch_queue_t createQueue = dispatch_queue_create("teachers", NULL);
    dispatch_async(createQueue, ^{
        NSArray *teachersArray;
        teachersArray = [self.updateProfileData queryDatabaseForTeachersAtSchool:schoolID];
        
        if (teachersArray)
        {
            NSDictionary *teacherDic = [teachersArray objectAtIndex:0];
            NSArray *teacherNames = [teacherDic objectForKey:@"teachers"];
            NSDictionary *teacherData = [teacherDic objectForKey:@"teacherData"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                self.masterListOfTeachers = teacherNames;
                self.masterListOfClasses = teacherData;
                
                [self filterTeachers];
                
                
            });
            
        }
    });
    
}
- (void)getKidsTeachersFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("kid_teachers", NULL);
    dispatch_async(createQueue, ^{
        NSArray *teachersArray;
        teachersArray = [self.updateProfileData getKidsTeachersFromDatabase:[self.kidData objectForKey:ID]];
        
        if (teachersArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSDictionary *tempDic = [teachersArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                    
                }
                else
                {
                    if([[tempDic objectForKey:@"teacherData"] count] == 0)
                    {
                        self.teacherTableView.hidden = true;
                        self.swipeLabel.hidden = true;
                        [self swapConstraints:1];
                    }
                    else
                    {
                        
                        self.teacherTableView.hidden =false;
                        self.swipeLabel.hidden = false;
                        [self swapConstraints:0];
                    }
                    
                    self.kidTeachers = [tempDic objectForKey:@"teacherData"];
                    [self filterTeachers];
                    [self.teacherTableView reloadData];

 
                    
                    
                }

                
            });
            
        }
    });
    
}

- (void)updateTeacherNames
{
    dispatch_queue_t createQueue = dispatch_queue_create("updateTeacherNames", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.introData updateTeacherNamesForUser:self.mainUserData.userID];
        if ([dataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertExistingUserIncorrectPassword andDelegate:self];
                    
                    
                }
                else
                {
                    [self.mainUserData resetTeacherNamesAndUserClasses];
                    
                    //if([self.mainUserData.accountType intValue] > 0)
                    [self.mainUserData addTeacherName:@{ID:self.mainUserData.userID, TEACHER_NAME:[NSString stringWithFormat:@"%@ %@",[self.mainUserData.userInfo objectForKey:@"prefix"], [self.mainUserData.userInfo objectForKey:USER_LAST_NAME]]}];
                    
                    
                    
                    for(NSDictionary *teacherData in [tempDic objectForKey:@"teacherNames"])
                    {
                        [self.mainUserData addTeacherName:teacherData];
                    }
                    
                    for(NSDictionary *userClassData in [tempDic objectForKey:@"usersClassData"])
                    {
                        [self.mainUserData addUserClass:userClassData];
                    }
                    
                    
                }
            });
            
        }
    });
    
}


- (void)deleteTeacherFromKidInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("deleteTeacher", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.updateProfileData deleteClass:[[self.kidTeachers objectAtIndex:self.rowSelected]objectForKey:@"classID"]fromKidInDatabase:[self.kidData objectForKey:ID]];
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
                    UIPickerView *tempPicker = (UIPickerView *)[self.gradeTF.inputView viewWithTag:zPickerTeacher];
                    [tempPicker selectRow:0 inComponent:0 animated:NO];
                    self.mainUserData.teacherNames = nil;
                    [self getKidsTeachersFromDatabase];
                    [self updateTeacherNames];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOAD_DATA" object:nil userInfo:nil];
                    
                }
            });
            
        }
    });
    
}

- (void)addTeacherToKidInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("addKidTeacher", NULL);
    dispatch_async(createQueue, ^{
    NSArray *dataArray;
        dataArray = [self.updateProfileData addClass:self.classSelected ToKidInDatabase:[self.kidData objectForKey:ID]]; 
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
                    for(NSDictionary *teacherData in [tempDic objectForKey:@"teacherNames"])
                    {
                        [self.mainUserData addTeacherName:teacherData];
                    }
                    UIPickerView *tempPicker = (UIPickerView *)[self.gradeTF.inputView viewWithTag:zPickerTeacher];
                    [tempPicker selectRow:0 inComponent:0 animated:NO];
                    self.teacherSelected = [[self.teachers objectAtIndex:0] objectForKey:ID];
                    self.teacherSelectedRow = 0;
                    
                    [self getKidsTeachersFromDatabase];
                    
                    self.gradeTF.text = @"";
                    self.gradeTF.hidden = true;
                    self.showAddTeacherButton.hidden = false;
                    [self.addUpdateButton setTitle:@"Update Kid" forState:UIControlStateNormal];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOAD_DATA" object:nil userInfo:nil];
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
        if(!self.classSelected)
            self.classSelected = @"999";
    }
        
    
    
    NSDictionary *tempDic = [[NSDictionary alloc]initWithObjects:@[kidID, self.firstNameTF.text, self.lastNameTF.text, self.classSelected, self.mainUserData.schoolIDselected, self.mainUserData.userID ] forKeys:@[KID_ID, KID_FIRST_NAME, KID_LAST_NAME, @"classID", SCHOOL_ID, USER_ID]];
    
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
                    [self filterTeachers];
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
    //NSLog(@"%@", self.firstNameTF.text);
    if(self.addingNewKid)
    {
        if(self.firstNameTFready && self.lastNameTFready && [self.gradeTF.text length] > 0)
        {
            self.addUpdateButton.enabled = true;
        }
        else
            self.addUpdateButton.enabled = false;

    }
    else
    {
        if(self.firstNameTFready && self.lastNameTFready)
        {
            self.addUpdateButton.enabled = true;
        }
        else
            self.addUpdateButton.enabled = false;

    }
    
    
    if([self.gradeTF.text length] > 0 && [self.teacherSelected length] > 0)
    {
        if(!self.addingNewKid)
            [self.addUpdateButton setTitle:@"Add Teacher" forState:UIControlStateNormal];
            
        self.addUpdateButton.enabled = true;
        
        
    }
    else
    {
        if(!self.addingNewKid)
            [self.addUpdateButton setTitle:@"Update Kid" forState:UIControlStateNormal];
    }
    
    
        

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

-(UIView *)createPickerWithTag:(NSInteger)tag
{
    UIPickerView *pickerView = [[UIPickerView alloc]init];
    pickerView.tag = tag;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [pickerView setShowsSelectionIndicator:YES];
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(hideKeyboard)];
    
    toolBar.barTintColor = [UIColor colorWithRed:0.820f green:0.835f blue:0.859f alpha:1.00f];
    
    toolBar.items = [[NSArray alloc] initWithObjects:barButtonDone,nil];
    barButtonDone.tintColor=[UIColor blackColor];
    
    
    UIView *pickerParentView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, 320, 216)];
    [pickerParentView addSubview:pickerView];
    [pickerParentView addSubview:toolBar];
/*
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickerViewTapped)];
    
    [tapGR setNumberOfTapsRequired:1];
    [tapGR setDelegate:self];
    [pickerView addGestureRecognizer:tapGR];
 */
    
    return pickerParentView;
}

- (void)pickerViewTapped
{
    if(self.gradeTF.isFirstResponder)
    {
        [self hideKeyboard];
    }
}

-(void)swapConstraints:(NSTimeInterval)animationTime
{
    if(self.teacherTableView.hidden)
    {
        [self.view removeConstraint:self.removeButtonConstraint];
        [self.view removeConstraint:self.origianalConstraint];
        [self.view removeConstraints:[self.teacherTableView constraints]];
        [self.view removeConstraints:[self.swipeLabel constraints]];

        [UIView animateWithDuration:animationTime animations:^{
            [self.view addConstraint:self.hiddenConstraint];
            
                        [self.view layoutIfNeeded];
        }];
    }
    else
    {
        [self.view removeConstraint:self.hiddenConstraint];

        [UIView animateWithDuration:animationTime animations:^{
            [self.view addConstraint:self.origianalConstraint];
            [self.view addConstraints:self.tableConstraints];
            [self.view addConstraints:self.labelConstraints];
            
            
            [self.view layoutIfNeeded];
        }];
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([self.mainUserData getTutorialStatusOfView:sv_UpdateKid])
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
    [self.mainUserData turnOffTutorialForView:sv_UpdateKid];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Add_Update_Kid_Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
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
    self.changesMade = NO;
    self.teacherAdded = NO;
    self.gradeTF.inputView = [self createPickerWithTag:zPickerTeacher];
    self.origianalConstraint = self.removeButtonConstraint;
    self.hiddenConstraint = [NSLayoutConstraint constraintWithItem:self.addUpdateButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.gradeTF attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
    self.tableConstraints = [self.teacherTableView constraints];
    self.labelConstraints = [self.swipeLabel constraints];
    
    [self getTeachersFromDatabase];
    if (self.addingNewKid)
    {
       
        [self.addUpdateButton setTitle:@"Add Student" forState:UIControlStateNormal];
        self.schoolTF.text = [self.mainUserData getSchoolNameFromID:self.mainUserData.schoolIDselected];
        self.header.text = @"Add a Student";
        self.teacherTableView.hidden = true;
        self.swipeLabel.hidden = true;
        self.showAddTeacherButton.hidden = true;
        
        [self swapConstraints:0];
    
        
        
        
    }
    else
    {
        
        self.firstNameTF.text = [self.kidData objectForKey:KID_FIRST_NAME];
        self.lastNameTF.text = [self.kidData objectForKey:KID_LAST_NAME];
        self.gradeTF.hidden = true;
        self.showAddTeacherButton.hidden = false;
        self.schoolTF.text = [self.mainUserData getSchoolNameFromID:[self.kidData objectForKey:SCHOOL_ID]];
        self.addUpdateButton.enabled = YES;
        self.gradeTFready = YES;
        self.firstNameTFready = YES;
        self.lastNameTFready = YES;
    }
}


- (IBAction)privacyPolicyButtonPressed
{
    //[self.navigationController popToRootViewControllerAnimated:YES];
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.myschoolintercom.com/privacy.php"]];

}

- (IBAction)showAddTeacherButtonPressed
{
    if(!self.addingNewKid)
    {
        self.showAddTeacherButton.hidden = true;
        self.gradeTF.hidden = false;
    
    }
}

- (IBAction)addTeacherButtonPressed
{
    self.teacherAdded = true;
   

    [self addTeacherToKidInDatabase];
}

- (IBAction)addUpdateButtonPressed:(UIButton *)sender
{
    [self hideKeyboard];
    
    if(self.changesMade && [sender.titleLabel.text isEqualToString:@"Add Teacher"])
    {
        [self addTeacherButtonPressed];
        [self updateKidInDatabase];
        
    }
    else if (!self.changesMade && [sender.titleLabel.text isEqualToString:@"Add Teacher"])
             [self addTeacherButtonPressed];
    else
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
    self.changesMade = YES;
    
    NSString *newString = textField.text;
    
    newString = [newString stringByReplacingCharactersInRange:range withString:string];

    
    switch (textField.tag)
    {
        case 1:
        {
            if ([[HelperMethods prepStringForValidation:newString] length] > 0)
                self.firstNameTFready = YES;
            else
                self.firstNameTFready = NO;
        }
            break;
        case 2:
        {
            if ([[HelperMethods prepStringForValidation:newString] length] > 0)
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
        
        case zAlertKidAddUpdatedSuccess:
            if(!self.teacherAdded)
                [self.navigationController popViewControllerAnimated:YES];
            else
            {
                self.teacherAdded = NO;
                self.changesMade = NO;
                self.addUpdateButton.enabled = NO;
                [self.addUpdateButton setTitle:@"Update Kid" forState:UIControlStateNormal];
            }
            break;
                    
    }
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.addingNewKid)
        return 0;
    else
        return self.kidTeachers.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.kidTeachers objectAtIndex:indexPath.row] objectForKey:@"teacherName"]];
    cell.detailTextLabel.text = [[self.kidTeachers objectAtIndex:indexPath.row]objectForKey:@"className"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertView * confirmDeleteAlert = [[UIAlertView alloc]initWithTitle:@"Remove Teacher" message:[ NSString stringWithFormat:@"Are you sure you want to remove %@?",[[self.kidTeachers objectAtIndex:indexPath.row]objectForKey:TEACHER_NAME]]   delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        confirmDeleteAlert.tag = zAlertConfirmRemoveTeacher;
        self.rowSelected = indexPath.row;
        
        [confirmDeleteAlert show];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        if(pickerView.tag == zPickerTeacher)
            return [self.teachers count];
    }
    else
    {
        NSArray *tempArray = [self.teacherData objectForKey:self.teacherSelected];
        if(tempArray)
            return [tempArray count];
        else
            return 0;
    }
    
    
    
    return 0;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(pickerView.tag == zPickerTeacher)
    {
        NSArray *tempArray = [self.teacherData objectForKey:self.teacherSelected];
        if(tempArray)
        {
            if([tempArray count] > 1)
            {
                self.classSelected = [[[self.teacherData objectForKey:self.teacherSelected]objectAtIndex:0]objectForKey:ID];
                return 2;
            }
            else
            {
                self.classSelected = [[[self.teacherData objectForKey:self.teacherSelected]objectAtIndex:0]objectForKey:ID];
                return 1;
            }
        }
        else
        {
            self.classSelected = @"0";
            return 1;
        }
    }
    else
        return 1;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    /*
    if(pickerView.tag == zPickerTeacher)
    {
        if(component == 0)
        {
            if([[[self.teachers objectAtIndex:row]objectForKey:ID] isEqualToString:@"999"])
                return @"No Teachers to Display";
            else
            {
                return [NSString stringWithFormat:@"%@ %@", [[self.teachers objectAtIndex:row] objectForKey:TEACHER_PREFIX], [[self.teachers objectAtIndex:row] objectForKey:TEACHER_LAST_NAME]];
                
            }
        }
        else
        {
            return [NSString stringWithFormat:@"%@", [[[self.teacherData objectForKey:self.teacherSelected]objectAtIndex:row] objectForKey:@"className"]];
        }
        
      
        
    }
     */
    
    return nil;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *retval = (id)view;
    if (!retval) {
        retval= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
    }
    if(pickerView.tag == zPickerTeacher)
    {
        if(component == 0)
        {
            if([[[self.teachers objectAtIndex:row]objectForKey:ID] isEqualToString:@"999"])
                retval.text = @"No Teachers to Display";
            else
            {
                retval.text = [NSString stringWithFormat:@"%@", [[self.teachers objectAtIndex:row] objectForKey:@"teacherName"]];
                
            }
        }
        else
        {
            retval.text = [NSString stringWithFormat:@"%@", [[[self.teacherData objectForKey:self.teacherSelected]objectAtIndex:row] objectForKey:@"className"]];
        }
    }

    retval.textAlignment = NSTextAlignmentCenter;
        retval.font = [UIFont systemFontOfSize:22];
        retval.adjustsFontSizeToFitWidth = YES;
    return retval;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        if(pickerView.tag == zPickerTeacher)
        {
                self.teacherSelected = [[self.teachers objectAtIndex:row] objectForKey:ID];
                self.teacherSelectedRow = row;
                if([[self.teacherData objectForKey:self.teacherSelected]count] > 1)
                {
                    self.gradeTF.text = [NSString stringWithFormat:@"%@ - %@", [[self.teachers objectAtIndex:self.teacherSelectedRow] objectForKey:@"teacherName"],
                                         [[[self.teacherData objectForKey:self.teacherSelected] objectAtIndex:0]objectForKey:@"className"]] ;
                }
                else
                    self.gradeTF.text = [NSString stringWithFormat:@"%@", [[self.teachers objectAtIndex:row]objectForKey:@"teacherName"]] ;
                [pickerView reloadAllComponents];
            
            
        }
    }
    else
    {
        self.classSelected = [[[self.teacherData objectForKey:self.teacherSelected] objectAtIndex:row]objectForKey:ID];
        self.gradeTF.text = [NSString stringWithFormat:@"%@ - %@", [[self.teachers objectAtIndex:self.teacherSelectedRow] objectForKey:@"teacherName"],
                             [[[self.teacherData objectForKey:self.teacherSelected] objectAtIndex:0]objectForKey:@"className"]] ;
        [pickerView reloadAllComponents];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertConfirmRemoveTeacher)
    {
        if (buttonIndex == 1)
        {
            [self deleteTeacherFromKidInDatabase];
            
        }
    
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.gradeTF.isFirstResponder && [self.gradeTF.text length] == 0 && ![[[self.teachers objectAtIndex:0]objectForKey:ID] isEqualToString:@"999"] )
    {
        //self.gradeTF.text = [NSString stringWithFormat:@"%@", [[self.teachers objectAtIndex:0]objectForKey:@"teacherName"]];
        self.teacherSelected = [[self.teachers objectAtIndex:0] objectForKey:ID];
        self.teacherSelectedRow = 0;
        self.classSelected = [[self.teachers objectAtIndex:0]objectForKey:@"classID"];
        self.gradeTF.text = [NSString stringWithFormat:@"%@ - %@", [[self.teachers objectAtIndex:self.teacherSelectedRow] objectForKey:@"teacherName"],
                             [[[self.teacherData objectForKey:self.teacherSelected] objectAtIndex:0]objectForKey:@"className"]] ;
        
    }
}


@end
