//
//  SwitchViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "SwitchViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SwitchViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITableView *schoolListTableView;
@property (nonatomic, strong) NSArray *allSchools;
@property (nonatomic) NSInteger rowSelected;
@property (nonatomic, strong) UpdateProfileModel *updateProfileData;


@end

@implementation SwitchViewController

- (UpdateProfileModel *)updateProfileData
{
    if(!_updateProfileData) _updateProfileData = [[UpdateProfileModel alloc]init];
    return _updateProfileData;
}

- (NSArray *)allSchools
{
    if (!_allSchools) _allSchools = [self.mainUserData getAllofUsersSchools];
    return _allSchools;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.headerLabel setFont:FONT_CHARCOAL_CY(17.0f)];
    
    self.schoolListTableView.delegate = self;
    self.schoolListTableView.dataSource = self;
    
    [self.mainUserData showAllSchoolsInNSLOG];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)menuPressed
{
    if([self.delegate respondsToSelector:@selector(snapshotOfViewAsImage:)])
    {
        [self.delegate snapshotOfViewAsImage:[UIView captureView:self.view]];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mainUserData getNumberOfSchools];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"switcherCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel *cellLabel = (UILabel *)[tableView viewWithTag:2];
    cellLabel.text = [[self.allSchools objectAtIndex:indexPath.row]objectForKey:SCHOOL_NAME];
    NSLog(@"%@", [[self.allSchools objectAtIndex:indexPath.row]objectForKey:BADGE_COUNT]);
    if([[[self.allSchools objectAtIndex:indexPath.row]objectForKey:BADGE_COUNT]intValue] > 0)
    {
        UILabel *badgeLabel = (UILabel *)[tableView viewWithTag:3];
        
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.size.height / 2;
        badgeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        badgeLabel.layer.borderWidth = 1.0f;
        
        if([[[self.allSchools objectAtIndex:indexPath.row]objectForKey:BADGE_COUNT]intValue] > 9)
        {
            badgeLabel.text = @"9+";
        }
        else
            badgeLabel.text = [[self.allSchools objectAtIndex:indexPath.row]objectForKey:BADGE_COUNT];
        
        [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
            badgeLabel.alpha = 1.0;
        }completion:^(BOOL finished) {
            //
        }];


    }
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, [[self.allSchools objectAtIndex:indexPath.row] objectForKey:SCHOOL_IMAGE_NAME]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        
        
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
        
        
        imageView.image = image;
        
    }

    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.mainUserData setActiveSchool:[[self.allSchools objectAtIndex:indexPath.row]objectForKey:ID]];
    
    if([self.delegate respondsToSelector:@selector(exitOutOfSchool)])
    {
        [self.delegate exitOutOfSchool];
    }
    
    [self menuPressed];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertView * confirmDeleteAlert = [[UIAlertView alloc]initWithTitle:@"Remove School" message:@"Are you sure you want to remove this school?  To add this school later click Restore Purchases in\n Settings->Update Profile"   delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        confirmDeleteAlert.tag = zAlertConfirmRemoveSchool;
        self.rowSelected = indexPath.row;
        
        [confirmDeleteAlert show];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
   // else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertConfirmRemoveSchool)
    {
        if (buttonIndex == 1)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[[self.allSchools objectAtIndex:self.rowSelected]objectForKey:ID]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if([self.mainUserData removeSchoolFromPhone:[[self.allSchools objectAtIndex:self.rowSelected]objectForKey:ID]])
            {
                if([self.delegate respondsToSelector:@selector(exitOutOfSchool)])
                {
                    [self.delegate exitOutOfSchool];
                }
                
                [self menuPressed];
                
            }
            else
                [self.schoolListTableView reloadData];
            
            dispatch_queue_t createQueue = dispatch_queue_create("changeStatus", NULL);
            dispatch_async(createQueue, ^{
                NSArray *dataArray;
                dataArray = [self.updateProfileData changeSchoolStatusForUser:[[self.allSchools objectAtIndex:self.rowSelected]objectForKey:ID] ofUser:self.mainUserData.userID isActive:@"0"];
                if ([dataArray count] == 1)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *tempDic = [dataArray objectAtIndex:0];
                        
                        if([[tempDic objectForKey:@"error"] boolValue])
                        {
                            [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                            
                        }
                    });
                    
                }
            });


        }
    }
}

@end
