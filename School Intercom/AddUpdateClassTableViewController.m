//
//  AddUpdateClassTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 8/15/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "AddUpdateClassTableViewController.h"


@interface AddUpdateClassTableViewController () <UITextFieldDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *addUpdateButton;
@property (weak, nonatomic) IBOutlet UITextField *classNameTF;
@property (weak, nonatomic) IBOutlet UITextField *gradeLevelTF;
@property (weak, nonatomic) IBOutlet UITextField *peridoTF;

@property (nonatomic, strong) AdminModel *adminData;

@end

@implementation AddUpdateClassTableViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Add_Update_Class_Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
    if(self.isNewClass)
    {
        self.headerLabel.text = @"Add Class";
        [self.addUpdateButton setTitle:@"Add" forState:UIControlStateNormal];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPushAlert:) name:@"DisplayAlert" object:nil];
    
    
}

- (void)showPushAlert:(NSNotification *)notification
{
    NSDictionary *data = [notification userInfo];
    
    [HelperMethods CreateAndDisplayOverHeadAlertInView:self.view withMessage:[data objectForKey:@"message"] andSchoolID:[data objectForKey:SCHOOL_ID]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)updateClassInDatabase
{
    
    
    dispatch_queue_t createQueue = dispatch_queue_create("updateClass", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData updateClass:[self.classData objectForKey:ID] withClassName:self.classNameTF.text andPeriod:self.peridoTF.text andGradeLevel:self.gradeLevelTF.text];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *success = [[UIAlertView alloc]initWithTitle:@"Update Class" message:@"Class information was updated successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                success.tag = zAlertAddEventSuccess;
                [success show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_TEACHER_CLASSES" object:nil userInfo:nil];
                //need to redownload teacher class info
                
            });
            
        }
    });
    
}

- (void)addNewClassInDatabase
{
    
    dispatch_queue_t createQueue = dispatch_queue_create("addClass", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData addClassForUser:self.mainUserData.userID withClassName:self.classNameTF.text andPeriod:self.peridoTF.text andGradeLevel:self.gradeLevelTF.text];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *success = [[UIAlertView alloc]initWithTitle:@"Add Class" message:@"Class was added successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                success.tag = zAlertAddEventSuccess;
                [success show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_TEACHER_CLASSES" object:nil userInfo:nil];
                   //need to redownload teacher class info
            });
            
        }
    });
    
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;
   
    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    
    
    
    
}


- (void)hideKeyboard
{
    [self.classNameTF resignFirstResponder];
    [self.peridoTF resignFirstResponder];
    [self.gradeLevelTF resignFirstResponder];

}




- (void)viewDidLoad {
    [super viewDidLoad];

    if(!self.isNewClass)
    {
        self.classNameTF.text = [self.classData objectForKey:@"className"];
        self.peridoTF.text = [self.classData objectForKey:@"periodNumber"];
        self.gradeLevelTF.text = [self.classData objectForKey:@"gradeLevel"];
    }
    
    self.classNameTF.delegate = self;
    self.peridoTF.delegate = self;
    self.gradeLevelTF.delegate = self;
    
     [self setupTapGestures];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed
{
      [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addUpdateButtonPressed:(UIButton *)sender
{
    [self.view endEditing:YES];
   
    if([[HelperMethods prepStringForValidation:self.classNameTF.text] length] > 0 )
    {
        
        sender.enabled = NO;
        
        if([sender.titleLabel.text isEqualToString:@"Add"])
        {
            [self addNewClassInDatabase];
        }
        else if([sender.titleLabel.text isEqualToString:@"Update"])
        {
            [self updateClassInDatabase];
        }
    }
    else
    {
        UIAlertView *moreInfo = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"The Class must have a name." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [moreInfo show];
    }

}




-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertAddEventSuccess)
    {
        self.addUpdateButton.enabled = YES;
        //[self.navigationController popViewControllerAnimated:YES];
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


#pragma mark - Table view data source


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
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
