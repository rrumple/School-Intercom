//
//  UpdateKidViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 7/28/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "UpdateKidViewController.h"

@interface UpdateKidViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *teacherTableView;
@property (nonatomic, strong) UpdateProfileModel *updateProfileData;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTF;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTF;
@property (weak, nonatomic) IBOutlet UITextField *schoolTF;
@property (weak, nonatomic) IBOutlet UITextField *gradeTF;

@property (weak, nonatomic) IBOutlet UIButton *addUpdateButton;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (nonatomic) BOOL gradeTFready;
@property (nonatomic) BOOL firstNameTFready;
@property (nonatomic) BOOL lastNameTFready;
@property (nonatomic, strong) NSArray *teachers;
@property (nonatomic, strong) NSArray *masterListOfTeachers;
@property (nonatomic, strong) NSArray *kidTeachers;

@property (nonatomic, strong) NSString *teacherSelected;
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
    
    if([self.masterListOfTeachers count] > 0 && [self.kidTeachers count] > 0)
    {
        for(NSDictionary *teacher in self.masterListOfTeachers)
        {
            for(NSDictionary *otherTeacher in self.kidTeachers)
            {
                if([[teacher objectForKey:ID] isEqualToString:[otherTeacher objectForKey:TEACHER_ID]])
                {
                    [tempTeacherArray removeObject:teacher];
                }
            }
        }
    }
    
    if([tempTeacherArray count] == 0)
        [tempTeacherArray addObject:@{TEACHER_PREFIX:@"No Teachers ", TEACHER_LAST_NAME:@"to Display", ID:@"999"}];
    
    self.teachers = tempTeacherArray;
    
    UIPickerView *tempPicker = (UIPickerView *)self.gradeTF.inputView;
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
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                self.masterListOfTeachers = teachersArray;
                
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


- (void)deleteTeacherFromKidInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("deleteTeacher", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.updateProfileData deleteTeacher:[[self.kidTeachers objectAtIndex:self.rowSelected]objectForKey:TEACHER_ID] fromKidInDatabase:[self.kidData objectForKey:ID]];
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
                    [self getKidsTeachersFromDatabase];
                    
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
        dataArray = [self.updateProfileData addTeacher:self.teacherSelected ToKidInDatabase:[self.kidData objectForKey:ID]];
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
                    [self getKidsTeachersFromDatabase];
                    self.gradeTF.text = @"";
                    self.gradeTF.hidden = true;
                    self.showAddTeacherButton.hidden = false;
                    [self.addUpdateButton setTitle:@"Update Kid" forState:UIControlStateNormal];
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
        if(!self.teacherSelected)
            self.teacherSelected = @"999";
    }
        
    
    
    NSDictionary *tempDic = [[NSDictionary alloc]initWithObjects:@[kidID, self.firstNameTF.text, self.lastNameTF.text, self.teacherSelected, self.mainUserData.schoolIDselected, self.mainUserData.userID ] forKeys:@[KID_ID, KID_FIRST_NAME, KID_LAST_NAME, TEACHER_ID, SCHOOL_ID, USER_ID]];
    
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
       
        [self.addUpdateButton setTitle:@"Add Kid" forState:UIControlStateNormal];
        self.schoolTF.text = [self.mainUserData getSchoolNameFromID:self.mainUserData.schoolIDselected];
        self.header.text = @"Add a Kid";
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
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [[self.kidTeachers objectAtIndex:indexPath.row] objectForKey:TEACHER_NAME], [HelperMethods convertGradeLevel:[[self.kidTeachers objectAtIndex:indexPath.row]objectForKey:@"grade"]appendGrade:YES]];
    if(![[[self.kidTeachers objectAtIndex:indexPath.row]objectForKey:TEACHER_SUBJECT] isEqualToString:@""])
        cell.detailTextLabel.text = [[self.kidTeachers objectAtIndex:indexPath.row]objectForKey:TEACHER_SUBJECT];
    
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
    
    if(pickerView.tag == zPickerTeacher)
        return [self.teachers count];
    
    
    return 0;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //if(pickerView.tag == zPickerTeacher)
    //  return 2;
    //else
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if(pickerView.tag == zPickerTeacher)
    {
        if([[[self.teachers objectAtIndex:row]objectForKey:ID] isEqualToString:@"999"])
            return @"No Teachers to Display";
        else if(![[[self.teachers objectAtIndex:row]objectForKey:TEACHER_SUBJECT]isEqualToString:@""])
        {
            return [NSString stringWithFormat:@"%@ %@ - %@ %@", [[self.teachers objectAtIndex:row] objectForKey:TEACHER_PREFIX], [[self.teachers objectAtIndex:row] objectForKey:TEACHER_LAST_NAME], [HelperMethods convertGradeLevel:[[self.teachers objectAtIndex:row] objectForKey:@"grade"]appendGrade:NO], [[self.teachers objectAtIndex:row]objectForKey:TEACHER_SUBJECT]];
        }
        else
        {
            return [NSString stringWithFormat:@"%@ %@ - %@", [[self.teachers objectAtIndex:row] objectForKey:TEACHER_PREFIX], [[self.teachers objectAtIndex:row] objectForKey:TEACHER_LAST_NAME], [HelperMethods convertGradeLevel:[[self.teachers objectAtIndex:row] objectForKey:@"grade"]appendGrade:YES]];
        }
        
    }
    
    return nil;
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerTeacher)
    {
        self.teacherSelected = [[self.teachers objectAtIndex:row] objectForKey:ID];
        if(![[[self.teachers objectAtIndex:row]objectForKey:TEACHER_SUBJECT]isEqualToString:@""])
        {
            self.gradeTF.text = [NSString stringWithFormat:@"%@ %@ - %@", [[self.teachers objectAtIndex:row]objectForKey:TEACHER_PREFIX], [[self.teachers objectAtIndex:row]objectForKey:TEACHER_LAST_NAME], [[self.teachers objectAtIndex:row]objectForKey:TEACHER_SUBJECT]];
            
        }
        else
        {
            self.gradeTF.text = [NSString stringWithFormat:@"%@ %@", [[self.teachers objectAtIndex:row]objectForKey:TEACHER_PREFIX], [[self.teachers objectAtIndex:row]objectForKey:TEACHER_LAST_NAME]];

        }
        
        
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
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
        if(![[[self.teachers objectAtIndex:0]objectForKey:TEACHER_SUBJECT] isEqualToString:@""])
        {
            self.gradeTF.text = [NSString stringWithFormat:@"%@ %@ - %@", [[self.teachers objectAtIndex:0]objectForKey:TEACHER_PREFIX], [[self.teachers objectAtIndex:0]objectForKey:TEACHER_LAST_NAME], [[self.teachers objectAtIndex:0]objectForKey:TEACHER_SUBJECT]];

        }
        else
        {
            self.gradeTF.text = [NSString stringWithFormat:@"%@ %@", [[self.teachers objectAtIndex:0]objectForKey:TEACHER_PREFIX], [[self.teachers objectAtIndex:0]objectForKey:TEACHER_LAST_NAME]];
        }
        self.teacherSelected = [[self.teachers objectAtIndex:0] objectForKey:ID];
        
    }
}


@end
