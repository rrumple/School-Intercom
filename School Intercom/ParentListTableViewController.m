//
//  ParentListTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 2/4/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "ParentListTableViewController.h"

@interface ParentListTableViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *parentData;
@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic, strong) UITextField *classRoomTextfield;
@property (strong, nonatomic) IBOutlet UITableView *parentListTableView;
@property (nonatomic, strong) NSString *classSelected;
@property (nonatomic) BOOL isFirstRun;
@end

@implementation ParentListTableViewController

- (AdminModel *)adminData
{
    if (!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)getParentsOfTeacherInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("getParents", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData getParentsOfClass:self.classSelected];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.parentData = databaseData;
                [self.parentListTableView reloadData];
                ;
                
            });
            
        }
    });
    
}

- (void)hideKeyboard
{
    [self.classRoomTextfield resignFirstResponder];
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
    if(self.classRoomTextfield.isFirstResponder)
    {
        [self hideKeyboard];
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
    
    [self setupTapGestures];
    self.isFirstRun = true;
    if([self.mainUserData.classData count] > 0)
    {
        self.classSelected = [[self.mainUserData.classData objectAtIndex:0]objectForKey:ID];
    }
    else
    {
        self.classSelected = @"0";
    }
   
    
    [self getParentsOfTeacherInDatabase];
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

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0)
        return 75;
    else
        return 0.01f;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0)
        return @"This is a list of Parents that have signed up and follow you on School Intercom.  They will see all calendar, news, and alerts that you send out for your class.";
    else
        return @"";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    else
        return [self.parentData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"parentCell";
    UITableViewCell *cell;
    
    
    if(indexPath.section == 0)
    {
        CellIdentifier = CELL_EXIT;
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        //UILabel *totalParentsLabel = (UILabel *)[cell viewWithTag:1];
        UITextField *classTF = (UITextField *) [cell viewWithTag:2];
        
        if(self.isFirstRun)
        {
            classTF.inputView = [self createPickerWithTag:zPickerClassRoom];
        if([self.mainUserData.classData count] > 0)
        {
            classTF.text = [[self.mainUserData.classData objectAtIndex:0] objectForKey:@"className"];
            self.classSelected = [[self.mainUserData.classData objectAtIndex:0]objectForKey:ID];
        }
        else
        {
            classTF.text = @"No Classes Found";
            self.classSelected = @"0";
            [classTF setEnabled:false];
        }
        self.classRoomTextfield = classTF;
            self.isFirstRun = false;
        }
        //totalParentsLabel.text = [NSString stringWithFormat:@"Total Parents : %lu", (unsigned long)[self.parentData count]];
    }
    else
    {
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.text = [[self.parentData objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.detailTextLabel.text = [[self.parentData objectAtIndex:indexPath.row]objectForKey:@"kidName"];
        
    }
    return cell;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if(pickerView.tag == zPickerClassRoom)
        return [self.mainUserData.classData count];
    
    
    return 0;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if(pickerView.tag == zPickerClassRoom)
    {
        return [[self.mainUserData.classData objectAtIndex:row] objectForKey:@"className"];
        
    }
    
    return nil;
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerClassRoom)
    {
        self.classSelected = [[self.mainUserData.classData objectAtIndex:row] objectForKey:ID];
        self.classRoomTextfield.text = [[self.mainUserData.classData objectAtIndex:row] objectForKey:@"className"];
        [self getParentsOfTeacherInDatabase];
        
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}


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
