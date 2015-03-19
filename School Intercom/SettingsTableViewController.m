//
//  SettingsTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/29/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()
@property (nonatomic ,strong) NSArray *cellsToShow;
@property (nonatomic) NSInteger sectionCount;
@property (nonatomic) NSInteger rowCount;

@end

@implementation SettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setProfileDatawithSections:(NSInteger)sectionCount andRows:(NSInteger)rowCount
{
    self.sectionCount = sectionCount;
    self.rowCount = rowCount;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    switch ([self.mainUserData.accountType intValue])
    {
        case utParent:
        case utTeacher:
        case utSecretary:
        case utPrincipal:
        case utSuperintendent:
        case utSales:
        case utSuperUser:
        case utBetaTester:
            self.cellsToShow = @[CELL_UPDATE_PROFILE, CELL_UPDATE_KIDS, CELL_ADD_SCHOOL, CELL_ADD_GRANDPARENT];
            [self setProfileDatawithSections:2 andRows:[self.cellsToShow count]];
            break;
        case utGrandparent:
            self.cellsToShow = @[CELL_UPDATE_PROFILE];
            [self setProfileDatawithSections:2 andRows:[self.cellsToShow count]];
            break;
            
    }

    UIView *menuBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 58)];
    UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
    
    [menuButton addTarget:self action:@selector(menuPressed) forControlEvents:UIControlEventTouchDown];
    
    [menuButton setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
    [menuBar addSubview:menuButton];
    
    [self.view addSubview:menuBar];
    
    UILabel *pageTitle = [[UILabel alloc]initWithFrame:CGRectMake(131, 19, 80, 21)];
    
    pageTitle.text = @"Settings";
    [pageTitle setTextAlignment:NSTextAlignmentCenter];
    [pageTitle setTextColor:[UIColor whiteColor]];
    
    
    
    [pageTitle setFont:FONT_CHARCOAL_CY(17.0f)];
    
    [self.view addSubview:pageTitle];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)menuPressed
{
    if([self.delegate respondsToSelector:@selector(snapshotOfViewAsImage:)])
    {
        [self.delegate snapshotOfViewAsImage:[UIView captureView:self.view]];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{

    
    if(self.mainUserData.isDemoInUse)
    {
        UIAlertView *demoModeAlert = [[UIAlertView alloc]initWithTitle:@"Demo User" message:@"Settings are disabled in Demo Mode" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [demoModeAlert show];
        return NO;
    }
            
    return YES;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_TO_UPDATE_PROFILE_VIEW])
    {
        UpdateProfileViewController *UPVC = segue.destinationViewController;
        UPVC.mainUserData = self.mainUserData;
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_UPDATE_KIDS_VIEW])
    {
        UpdateKidsViewController *UKVC = segue.destinationViewController;
        UKVC.mainUserData = self.mainUserData;
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_ADD_SCHOOL_VIEW])
    {
        AddSchoolViewController *ASVC = segue.destinationViewController;
        ASVC.mainUserData = self.mainUserData;
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_ADD_GRANDPARENT])
    {
        AddGrandparentViewController *AGVC = segue.destinationViewController;
        AGVC.mainUserData = self.mainUserData;
    }
}

- (IBAction)resetTutorialPressed
{
    [self.mainUserData resetTutorials];
    
    UIAlertView *resetTutorialAlert = [[UIAlertView alloc]initWithTitle:@"Tutorials Reset" message:@"Each screen will now display it's tutorial the first time you view it." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [resetTutorialAlert show];
}


#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 1.0f;
    else
        return 44.0f;
}
 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (section == 0)
        return 1;
    else
        return self.rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    if(indexPath.section == 0)
       identifier = CELL_EMPTY;
    else
        identifier = [self.cellsToShow objectAtIndex:indexPath.row];

    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    // Configure the cell...
    
    return cell;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the.0 class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
