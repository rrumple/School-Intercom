//
//  ManageUsersViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/28/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "ManageUsersViewController.h"
#import "AdminModel.h"
#import "ManageSingleUserTableViewController.h"
#import "AddNewUserTableViewController.h"

@interface ManageUsersViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userGroupTextfield;
@property (weak, nonatomic) IBOutlet UITableView *userTableview;
@property (nonatomic, strong) NSArray *userData;
@property (nonatomic, strong) NSArray *userTypes;
@property (nonatomic, strong) NSArray *groupPickerValues;
@property (nonatomic) NSInteger userTypeSelected;
@property (nonatomic, strong) NSString *idToQuery;
@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic, strong) NSString *userIDSelected;
@property (nonatomic, strong) NSString *corpIDSelected;


@end

@implementation ManageUsersViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

-(void)setupGroupPicker
{
    
    
    switch ([self.mainUserData.accountType intValue])
    {
        case utSecretary://schoolAdmin is logged in
            self.groupPickerValues = @[@"0", @"1"];
            break;
        case utPrincipal:
            self.groupPickerValues = @[@"0", @"1", @"2"];
            break;
        case utSuperintendent://Corp Admin is logged in
            self.groupPickerValues = @[@"0", @"1", @"2", @"3"];
            break;
        case utSales:
            self.groupPickerValues = @[@"3", @"4"];
            //sales are not allowed to send alerts
            break;
        case utSuperUser://Super User is logged in
            self.groupPickerValues = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7"];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.needsReload)
    {
        [self queryDatabaseforUsers];
        self.needsReload = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userTypes = [HelperMethods getDictonaryOfUserTypes];
    [self setupGroupPicker];
    // Do any additional setup after loading the view.
    self.userGroupTextfield.inputView = [self createPickerWithTag:zPickerGroup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hideKeyboard
{
    
    [self.userGroupTextfield resignFirstResponder];
    
    
}

-(void)queryDatabaseforUsers
{
    dispatch_queue_t createQueue = dispatch_queue_create("queryDatabaseForUsers", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData queryDatabaseForUsers:self.idToQuery andQueryType:[NSString stringWithFormat:@"%li",(long)self.userTypeSelected] forUserID:self.mainUserData.userID];
        
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
                        
                        
                        self.userData = [tempDic objectForKey:@"data"];
                        [self.userTableview reloadData];
                        
                    }
                });
                
                
                
                
                
            });
            
        }
    });
}


-(void)setupDatabaseQuery
{
    self.idToQuery = @"";
    switch ([self.mainUserData.accountType intValue])
    {
        case utSecretary:
            switch (self.userTypeSelected)
        {
            case utParent://needs all parents of one school
            case utTeacher:
                self.idToQuery = self.mainUserData.schoolIDselected;
                break;
        }
            break;
        case utPrincipal:
            switch (self.userTypeSelected)
        {
            case utParent:
            case utTeacher:
            case utSecretary:
                self.idToQuery = self.mainUserData.schoolIDselected;
                break;
        }

            break;
        case utSuperintendent:
            switch (self.userTypeSelected)
        {
            case utParent:
            case utTeacher:
            case utSecretary:
            case utPrincipal:
                self.idToQuery = [self.mainUserData.schoolData objectForKey:SCHOOL_CORP_ID];
                break;
        }

            break;
        case utSales:
            switch (self.userTypeSelected)
        {
            case utPrincipal:
                break;
            case utSuperintendent:
                break;
        }

            break;
        case utSuperUser:
            switch (self.userTypeSelected)
        {
            case utParent:
                break;
            case utTeacher:
                break;
            case utSecretary:
                break;
            case utPrincipal:
                break;
            case utSuperintendent:
                break;
            case utSales:
                break;
            case utSuperUser:
                break;
            case utBetaTester:
                break;
        }

            break;
    }
    
    [self queryDatabaseforUsers];
}

- (void)pickerViewTapped
{
    if(self.userGroupTextfield.isFirstResponder)
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


- (void)deleteUserFromDatabase
{
    if(self.corpIDSelected == (id)[NSNull null])
        self.corpIDSelected = @"";
    
    dispatch_queue_t createQueue = dispatch_queue_create("deleteUser", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData deleteUserFromDatabase:self.userIDSelected];
        
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
                        
                        
                        [self queryDatabaseforUsers];
                    }
                });
                
                
                
                
                
            });
            
        }
    });
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_EDIT_SINGLE_USER])
    {
        ManageSingleUserTableViewController *MSUTVC = segue.destinationViewController;
        MSUTVC.mainUserData = self.mainUserData;
        MSUTVC.userIDSelected = self.userIDSelected;
        MSUTVC.queryType = [NSString stringWithFormat:@"%li",(long)self.userTypeSelected];
        
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_ADD_NEW_USER])
    {
        AddNewUserTableViewController *ANUTVC = segue.destinationViewController;
        ANUTVC.mainUserData = self.mainUserData;
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark Delegate Section


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.groupPickerValues count];

}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerGroup)
    {
        
        return [self.userTypes
                 objectAtIndex:[[self.groupPickerValues objectAtIndex:row] intValue]];
        
    }
    
    return @"";
}




-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerGroup)
    {
        self.userGroupTextfield.text =  [self.userTypes
                                      objectAtIndex:[[self.groupPickerValues objectAtIndex:row] intValue]];
        self.userTypeSelected = [[self.groupPickerValues objectAtIndex:row]intValue];
        
        [self setupDatabaseQuery];
    }
    
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.userData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"userCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *detailLabel = (UILabel *)[cell viewWithTag:2];
    
    
    nameLabel.text = [[self.userData objectAtIndex:indexPath.row]objectForKey:@"name"];

    detailLabel.text = [[self.userData objectAtIndex:indexPath.row]objectForKey:@"detail"];
    return cell;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.userGroupTextfield.isFirstResponder)
    {
        if ([self.userGroupTextfield.text isEqualToString:@""])
        {
            self.userGroupTextfield.text =  [self.userTypes
                                             objectAtIndex:[[self.groupPickerValues objectAtIndex:0] intValue]];
            self.userTypeSelected = [[self.groupPickerValues objectAtIndex:0]intValue];
            
            [self setupDatabaseQuery];

        }
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.userIDSelected = [[self.userData objectAtIndex:indexPath.row]objectForKey:ID];
    [self performSegueWithIdentifier:SEGUE_TO_EDIT_SINGLE_USER sender:self];
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
     if([self.mainUserData.accountType intValue] == utSuperUser)
         return YES;
     else
         return NO;
     
 }



 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.userIDSelected = [[self.userData objectAtIndex:indexPath.row]objectForKey:ID];
        self.corpIDSelected = [[self.userData objectAtIndex:indexPath.row]objectForKey:CORP_ID];

        UIAlertView *deleteConfrimAlert = [[UIAlertView alloc]initWithTitle:@"Remove User" message:[NSString stringWithFormat:@"You are about to remove %@ from the database. Are you sure?", [[self.userData objectAtIndex:indexPath.row] objectForKey:@"name"]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        deleteConfrimAlert.tag = zAlertDeleteUser;
        [deleteConfrimAlert show];

        
    }
 
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertDeleteUser)
    {
        if(buttonIndex == 1)
        {
            [self deleteUserFromDatabase];
        }
    }
}

@end
