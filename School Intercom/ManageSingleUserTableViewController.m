//
//  ManageSingleUserTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/29/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "ManageSingleUserTableViewController.h"
#import "AdminModel.h"
#import "SelectUsertypeTableViewController.h"
#import "IntroModel.h"
#import "UsersSchoolsTableViewController.h"
#import "ManageUsersViewController.h"

@interface ManageSingleUserTableViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NSArray *cellsToShow;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UILabel *accountTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pushPinLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdOnLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceVersionLabel;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordButton;
@property (weak, nonatomic) IBOutlet UILabel *numOfSchoolsLabel;
@property (nonatomic) int numOfSchools;

@property (nonatomic, strong) NSArray *userTypes;
@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic, strong) IntroModel *introData;
@property (nonatomic, strong) NSDictionary *userData;

@end

@implementation ManageSingleUserTableViewController

- (IntroModel *)introData
{
    if (!_introData) _introData = [[IntroModel alloc]init];
    return  _introData;
}

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)setSchoolLabel
{
    NSString *schoolText;
    if(self.numOfSchools == 1)
        schoolText = @"School";
    else
        schoolText = @"Schools";
    
    
    self.numOfSchoolsLabel.text = [NSString stringWithFormat:@"%i %@", self.numOfSchools, schoolText];

}

- (void)subtractOneFromSchoolLabel
{
    self.numOfSchools--;
    [self setSchoolLabel];
}

- (void)addOneToSchoolLabel
{
    self.numOfSchools++;
    [self setSchoolLabel];
}

- (void)recoverPasswordForEmail:(NSString *)email
{
    if ([HelperMethods isEmailValid:email])
    {
        dispatch_queue_t createQueue = dispatch_queue_create("resetPassword", NULL);
        dispatch_async(createQueue, ^{
            NSArray *dataArray;
            dataArray = [self.introData resetPasswordForEmail:email];
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
                        self.resetPasswordButton.enabled = false;
                        [self.resetPasswordButton setTitle:@"Reset Successful" forState:UIControlStateDisabled];
                        
                        
                    }
                });
                
            }
        });
        
    }
    else
    {
        //display alert for invalid email
    }
}

- (void)updateUserInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("updateUser", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData updateUserInDatabseWithFirstName:self.firstNameTextfield.text andLastName:self.lastNameTextfield.text andUserType:self.userTypeSelected andEmail:self.emailTextField.text withPrefix:@"" andGrade:@"" andSubject:@"" andUserID:self.userIDSelected];
        
        if (dataArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *tempDic = [dataArray objectAtIndex:0];
                    
                    if([[tempDic objectForKey:@"error"] boolValue])
                    {
                        [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                        
                    }
                    else
                    {
                        for (id viewController in self.navigationController.viewControllers)
                        {
                            if([viewController isKindOfClass:[ManageUsersViewController class]])
                            {
                                ManageUsersViewController *MUVC = viewController;
                                MUVC.needsReload = YES;
                                [self.navigationController popViewControllerAnimated:YES];
                                break;
                            }
                            
                        }

                        
                    }
                });
                
                
                
                
                
            });
            
        }
    });

}

-(void)hideKeyboard
{
    
    
    [self.firstNameTextfield resignFirstResponder];
    [self.lastNameTextfield resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    
    
    
    
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;
    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    
}

- (void)getUserDataFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("queryDatabaseForUsers", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData queryDatabaseForSingleUser:self.userIDSelected andQueryType:self.queryType forUserID:self.mainUserData.userID];
        
        if (dataArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *tempDic = [dataArray objectAtIndex:0];
                    
                    if([[tempDic objectForKey:@"error"] boolValue])
                    {
                        [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                        
                    }
                    else
                    {
                        
                        self.numOfSchools = [[tempDic objectForKey:@"numOfSchools"] intValue];
                        [self setSchoolLabel];
                        
                        NSDictionary *userdic = [[tempDic objectForKey:@"data"]objectAtIndex:0];
                        self.userData = userdic;
                        self.firstNameTextfield.text = [userdic objectForKey:USER_FIRST_NAME];
                        self.lastNameTextfield.text = [userdic objectForKey:USER_LAST_NAME];
                        self.emailTextField.text = [userdic objectForKey:USER_EMAIL];
                        
                        self.userTypeSelected = [userdic objectForKey:USER_ACCOUNT_TYPE];
                        NSString *pushPin;
                        if([[userdic objectForKey:@"pushPin"]boolValue])
                            pushPin = @"Valid";
                        else
                            pushPin = @"Invalid";
                        self.pushPinLabel.text = pushPin;
                        if([userdic objectForKey:@"userCreatedOn"] != (id)[NSNull null])
                            self.createdOnLabel.text = [userdic objectForKey:@"userCreatedOn"];
                        if([userdic objectForKey:DEVICE_MODEL] != (id)[NSNull null])
                            self.deviceModelLabel.text = [userdic objectForKey:DEVICE_MODEL];
                        if([userdic objectForKey:DEVICE_VERSION] != (id)[NSNull null])
                            self.deviceVersionLabel.text = [userdic objectForKey:DEVICE_VERSION];
                    }
                });
                
                
                
                
                
            });
            
        }
    });

}

- (void)setUserTypeSelected:(NSString *)userTypeSelected
{
    
    _userTypeSelected = userTypeSelected;
    
    self.accountTypeLabel.text = [self.userTypes objectAtIndex:[userTypeSelected intValue]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getUserDataFromDatabase];
    
    [self setupTapGestures];
    self.userTypes = [HelperMethods getDictonaryOfUserTypes];
    self.tableView.rowHeight = 44;
    
    self.cellsToShow = @[CELL_EXIT, CELL_FIRST_NAME, CELL_LAST_NAME, CELL_EMAIL, CELL_ACCOUNT_TYPE, CELL_SCHOOLS, CELL_PUSHPIN, CELL_CREATED_ON, CELL_DEVICE_MODEL, CELL_DEVICE_VERSION, CELL_RESET_PASSWORD];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)resetPasswordPressed
{
    [self recoverPasswordForEmail:self.emailTextField.text];
}

- (IBAction)saveChangesButtonPressed
{
    self.saveChangesButton.hidden = true;
    [self updateUserInDatabase];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section)
    {
        case 0: return 1;
            break;
        case 1: return 2;
            break;
        case 2: return 8;
            break;
            
    }
    return 0;
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    
    identifier = [self.cellsToShow objectAtIndex:indexPath.row];
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:SEGUE_TO_SELECT_USER_TYPE])
    {
        SelectUsertypeTableViewController *SUTTVC = segue.destinationViewController;
        SUTTVC.usertypeSelected = self.userTypeSelected;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_USERS_SCHOOLS])
    {
        UsersSchoolsTableViewController *USTVC = segue.destinationViewController;
        USTVC.userIDSelected = self.userIDSelected;
        USTVC.mainUserData = self.mainUserData;
    }
   

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2 && indexPath.row == 1 )
    {
        [self performSegueWithIdentifier:SEGUE_TO_SELECT_USER_TYPE sender:self];
    }
    else if(indexPath.section == 2 && indexPath.row == 2)
    {
        [self performSegueWithIdentifier:SEGUE_TO_USERS_SCHOOLS sender:self];
        
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.tableView endEditing:YES];
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    self.saveChangesButton.hidden = false;
    return YES;
}

@end
