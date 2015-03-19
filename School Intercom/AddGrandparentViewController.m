//
//  AddGrandparentViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 2/21/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "AddGrandparentViewController.h"
#import "UpdateProfileModel.h"

@interface AddGrandparentViewController () <UITextFieldDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UpdateProfileModel *updateData;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendInviteButton;
@property (weak, nonatomic) IBOutlet UITableView *grandparentTableview;
@property (weak, nonatomic) IBOutlet UILabel *tableviewLabel;
@property (nonatomic, strong) NSArray *grandparentData;
@property (nonatomic) NSInteger rowSelected;


@end

@implementation AddGrandparentViewController

- (UpdateProfileModel *)updateData
{
    if (!_updateData) _updateData = [[UpdateProfileModel alloc]init];
    return _updateData;
}



- (void)sendInviteToGrandParent
{
    dispatch_queue_t createQueue = dispatch_queue_create("sendGrandparentInvite", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.updateData addGrandparent:self.firstNameTextField.text lastName:self.lastNameTextfield.text withEmail:self.emailTextField.text parentUserId:self.mainUserData.userID atSchool:self.mainUserData.schoolIDselected];
        if ([dataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    if([[tempDic objectForKey:@"errorCode"] integerValue] == 9999)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Schools Added" message:[NSString stringWithFormat:@"%@ already has an active account with School Intercom, your schools have been added to their account.", self.emailTextField.text] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        alert.tag = zAlertAddGrandparentSuccess;
                        [alert show];

                    }
                    else
                        [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                    
                }
                else
                {
                    
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invitaion Sent" message:[NSString stringWithFormat:@"Instructions on how to setup their new account has been sent to %@", self.emailTextField.text] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    alert.tag = zAlertAddGrandparentSuccess;
                    [alert show];
                    
                }
                [self getGrandparentDataFromDatabase];
            });
            
        }
    });

}

- (void)checkToSeeIfButtonShouldBeEnabled
{
    
    
    if([[HelperMethods prepStringForValidation:self.firstNameTextField.text] length] > 0 && [[HelperMethods prepStringForValidation:self.lastNameTextfield.text] length] > 0 && [self.emailTextField.text length] > 0 && [HelperMethods isEmailValid:self.emailTextField.text])
    {
        
        self.sendInviteButton.enabled = true;
        
    }
    else
    {
        self.sendInviteButton.enabled = false;
    }
    
    
    
    
}

-(void)hideKeyboard
{

    [self checkToSeeIfButtonShouldBeEnabled];

    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextfield resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;
    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    
    
}

- (void)getGrandparentDataFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("getGrandparents", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.updateData getGrandparentsOfUserID:self.mainUserData.userID];
        if (dataArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.grandparentTableview.hidden = false;
                self.tableviewLabel.hidden = false;
                
                self.grandparentData = dataArray;
                
                [self.grandparentTableview reloadData];
                
                
            });
            
        }
        else
        {
            self.grandparentTableview.hidden = true;
            self.tableviewLabel.hidden = true;
        }
    });

}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self setupTapGestures];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkToSeeIfButtonShouldBeEnabled) name:UITextFieldTextDidChangeNotification object:nil];
 
    [self getGrandparentDataFromDatabase];
   
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendInviteButtonPressed
{
    [self sendInviteToGrandParent];
}

- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    return true;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == zAlertAddGrandparentSuccess)
        [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.grandparentData.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"grandparentCell"];
    
    
    cell.textLabel.text = [[self.grandparentData objectAtIndex:indexPath.row]objectForKey:@"name"];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return  0.01f;
}


@end
