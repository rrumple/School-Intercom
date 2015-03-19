//
//  AddNewUserTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 1/4/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "AddNewUserTableViewController.h"
#import "SelectUsertypeTableViewController.h"
#import "AllSchoolsTableViewController.h"
#import "AdminModel.h"

@interface AddNewUserTableViewController ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UILabel *schoolSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *corporationSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *addUserButton;
@property (nonatomic, strong) NSArray *userTypes;
@property (nonatomic, strong) AdminModel *adminData;
@property (weak, nonatomic) IBOutlet UITableViewCell *gradeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *subjectCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *prefixCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *schoolCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *corporationCell;
@property (weak, nonatomic) IBOutlet UITextField *prefixTextField;
@property (weak, nonatomic) IBOutlet UITextField *gradeTextField;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (nonatomic, strong) NSArray *prefixes;
@property (nonatomic, strong) NSArray *grades;
@property (nonatomic, strong) NSString *gradeSelected;
@property (nonatomic) BOOL isCorporationSearch;

@end

@implementation AddNewUserTableViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
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
    if(self.gradeTextField.isFirstResponder || self.prefixTextField.isFirstResponder)
    {
        [self hideKeyboard];
    }
}


- (void)checkToSeeIfButtonsNeedUnhidden
{
        if([self.firstNameTextField.text length] > 1 && [self.lastNameTextField.text length] > 1 && [self.emailTextField.text length] > 1 && (![self.schoolSelectedLabel.text isEqualToString:@"0 Selected"] || ![self.corporationSelectedLabel.text isEqualToString:@"Not Selected"]) && ![self.accountTypeLabel.text isEqualToString:@"n/a"])
    {
        if([self.userTypeSelected intValue] == utTeacher)
        {
            if([self.prefixTextField.text length] > 1 && [self.gradeTextField.text length] >1 )
                self.addUserButton.enabled = true;
        }
        else
        {
             self.addUserButton.enabled = true;
        }
       
    }
}

-(void)hideKeyboard
{
    [self checkToSeeIfButtonsNeedUnhidden];
    
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.prefixTextField resignFirstResponder];
    [self.gradeTextField resignFirstResponder];
    [self.subjectTextField resignFirstResponder];
    
    
    
    
}

-(void)addNewUserToDatabase
{
    NSString *corpID;
    NSString *schoolID;
    if(self.corpSelected)
    {
        corpID = [self.corpSelected objectForKey:ID];
        schoolID = @"";
        
    }
    else
    {
        schoolID = [self.schoolSelected objectForKey:ID];
        corpID = @"";
    }
    
    if([HelperMethods isEmailValid:self.emailTextField.text])
    {
        dispatch_queue_t createQueue = dispatch_queue_create("addUsertoDatabase", NULL);
        dispatch_async(createQueue, ^{
            NSArray *dataArray;
            dataArray = [self.adminData addUserToDatabseWithFirstName:self.firstNameTextField.text andLastName:self.lastNameTextField.text andUserType:self.userTypeSelected andEmail:self.emailTextField.text toSchoolID:schoolID withPrefix:self.prefixTextField.text andGrade:self.gradeSelected andSubject:self.subjectTextField.text andCorpID:corpID];
            
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
                            
                            
                            //user added alert
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    });
                    
                    
                    
                    
                    
                });
                
            }
        });

    }
    else
    {
        //uialert view invaild email address
    }
    
    
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;
    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.grades = [HelperMethods arrayOfGradeLevels];
    self.prefixes = [HelperMethods arrayOfPrefixes];
    self.subjectTextField.text = @"";
    self.gradeSelected = @"";
    self.prefixTextField.text = @"";
    self.gradeTextField.inputView = [self createPickerWithTag:zPickerGrade];
    self.prefixTextField.inputView = [self createPickerWithTag:zPickerPrefix];
    
    
    self.userTypes = [HelperMethods getDictonaryOfUserTypes];
    [self setupTapGestures];
    self.tableView.rowHeight = 44;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setSchoolSelected:(NSDictionary *)schoolSelected
{
    _schoolSelected = schoolSelected;
    
    self.schoolSelectedLabel.text = [self.schoolSelected objectForKey:SCHOOL_NAME];
    [self checkToSeeIfButtonsNeedUnhidden];

}

- (void)setCorpSelected:(NSDictionary *)corpSelected
{
    _corpSelected = corpSelected;
    
    self.corporationSelectedLabel.text = [self.corpSelected objectForKey:@"name"];
    [self checkToSeeIfButtonsNeedUnhidden];
    
}


- (void)setUserTypeSelected:(NSString *)userTypeSelected
{
    
    _userTypeSelected = userTypeSelected;
    
    self.accountTypeLabel.text = [self.userTypes objectAtIndex:[userTypeSelected intValue]];
    
    if([userTypeSelected intValue] == utTeacher)
    {
        self.prefixCell.hidden = false;
        self.gradeCell.hidden = false;
        self.subjectCell.hidden = false;
        
        [self.tableView reloadData];
    }
    else if([userTypeSelected intValue] == utSuperintendent)
    {
        self.corporationCell.hidden = false;
        self.schoolCell.hidden = true;
    }
    else
    {
        self.prefixCell.hidden = true;
        self.gradeCell.hidden = true;
        self.subjectCell.hidden = true;
        self.corporationCell.hidden = true;
        self.schoolCell.hidden = false;
        
        [self.tableView reloadData];
    }
    [self checkToSeeIfButtonsNeedUnhidden];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addUserButtonPressed
{
    [self addNewUserToDatabase];
}
- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:SEGUE_TO_SELECT_USER_TYPE])
    {
        SelectUsertypeTableViewController *SUTTVC = segue.destinationViewController;
        SUTTVC.usertypeSelected = @"999";
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_LIST_ALL_SCHOOLS])
    {
        AllSchoolsTableViewController *ASTVC = segue.destinationViewController;
        ASTVC.mainUserData = self.mainUserData;
        ASTVC.isCorporationSearch = self.isCorporationSearch;
        ASTVC.isManagingSchools = false;
    }
    
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if(pickerView.tag == zPickerPrefix)
        return [self.prefixes count];
    else if(pickerView.tag == zPickerGrade)
        return [self.grades count];
    
    
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
    
    if(pickerView.tag == zPickerGrade)
    {
        return [HelperMethods convertGradeLevel:[self.grades objectAtIndex:row] appendGrade:YES];
    }
    else if(pickerView.tag == zPickerPrefix)
    {
        return [self.prefixes objectAtIndex:row];
    }
    
    return nil;
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerGrade)
    {
        self.gradeTextField.text = [HelperMethods convertGradeLevel:[self.grades objectAtIndex:row] appendGrade:YES];
        self.gradeSelected = [self.grades objectAtIndex:row];
    }
    else if (pickerView.tag == zPickerPrefix)
    {
        self.prefixTextField.text = [self.prefixes objectAtIndex:row];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}


#pragma mark - Table view data source
/*
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
        case 2: return 4;
            break;
            
    }
    return 0;
}
*/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2 && indexPath.row == 3 )
    {
        [self performSegueWithIdentifier:SEGUE_TO_SELECT_USER_TYPE sender:self];
    }
    else if(indexPath.section == 2 && indexPath.row == 4)
    {
        self.isCorporationSearch = NO;
        [self performSegueWithIdentifier:SEGUE_TO_LIST_ALL_SCHOOLS sender:self];
    }
    else if(indexPath.section == 2 && indexPath.row == 5)
    {
        self.isCorporationSearch = YES;
        [self performSegueWithIdentifier:SEGUE_TO_LIST_ALL_SCHOOLS sender:self];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self checkToSeeIfButtonsNeedUnhidden];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.prefixTextField isFirstResponder] && [self.prefixTextField.text isEqualToString:@""])
    {
        self.prefixTextField.text = [self.prefixes objectAtIndex:0];

    }
    else if ([self.gradeTextField isFirstResponder] && [self.gradeTextField.text isEqualToString:@""])
    {
        self.gradeTextField.text = [HelperMethods convertGradeLevel:[self.grades objectAtIndex:0] appendGrade:YES];
        self.gradeSelected = [self.grades objectAtIndex:0];

    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell  *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.hidden)
        return 0.0;
    else
        return 44.0;
    
}

/*

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:  forIndexPath:indexPath];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
