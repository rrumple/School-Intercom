//
//  UpdateKidsViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/29/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "UpdateKidsViewController.h"
#import "UpdateKidViewController.h"

@interface UpdateKidsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *kidsTableView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (nonatomic, strong) UpdateProfileModel *updateProfileData;
@property (nonatomic, strong) NSArray *kidsArray;
@property (nonatomic, strong) NSMutableArray *textfields;
@property (nonatomic) BOOL keyboardUP;

@property (nonatomic, strong) NSDictionary *kidDicToEdit;
@property (nonatomic) BOOL addingNewKid;
@end

@implementation UpdateKidsViewController

- (NSMutableArray *)textfields
{
    if(!_textfields) _textfields = [[NSMutableArray alloc]init];
    return _textfields;
}

- (NSDictionary *)kidDicToEdit
{
    if (!_kidDicToEdit) _kidDicToEdit = [[NSDictionary alloc]init];
    return _kidDicToEdit;
}

- (NSArray *)kidsArray
{
    if(!_kidsArray) _kidsArray = [[NSArray alloc] init];
    return _kidsArray;
}

- (UpdateProfileModel *)updateProfileData
{
    if(!_updateProfileData) _updateProfileData = [[UpdateProfileModel alloc]init];
    return _updateProfileData;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadKidsFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("loadKids", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.updateProfileData getKidsInfoFromDatabase:self.mainUserData.userID];
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
                    if([[[dataArray objectAtIndex:0]objectForKey:@"kidsData"]count] == 0)
                    {
                        UIAlertView *noKidsAlert = [[UIAlertView alloc]initWithTitle:@"No Kids Found" message:@"Press the add kid button to add kids to your account" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        [noKidsAlert show];
                    }
                    
                    
                        self.kidsArray = [[dataArray objectAtIndex:0] objectForKey:@"kidsData"];
                        [self.kidsTableView reloadData];                        
                        //[self.textfields removeAllObjects];
                    
                    
                }
            });
            
        }
    });

}


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.kidsTableView.delegate = self;
    self.kidsTableView.dataSource = self;
    
    [self.headerLabel setFont:FONT_CHARCOAL_CY(17.0f)];
    
    

    
    
    self.keyboardUP = false;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadKidsFromDatabase];
}


- (IBAction)addPressed:(id)sender
{
    
    self.kidDicToEdit = nil;
    self.addingNewKid = YES;
    [self performSegueWithIdentifier:SEGUE_TO_UPDATE_KID_VIEW sender:self];
    
    
    /*
    NSMutableArray *tempArray = [self.kidsArray mutableCopy];
    NSDictionary *tempDic = [[NSDictionary alloc]initWithObjects:@[@"", @"", @"", @"999"] forKeys:@[KID_FIRST_NAME, KID_GRADE_LEVEL, KID_LAST_NAME, ID]];
    [tempArray addObject:tempDic];
    self.kidsArray = tempArray;

    
    [self.kidsTableView reloadData];
    [self.textfields removeAllObjects];
     */
 
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
    return  [self.kidsArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"kidCell";
    static NSString *CellIdentifier2 = @"addCell";
    
    UITableViewCell *cell;
    
    if(indexPath.row < [self.kidsArray count])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        
        
        NSDictionary *kidsDic = [self.kidsArray objectAtIndex:indexPath.row];
        UILabel *fName =  (UILabel *)[cell.contentView viewWithTag:2];
        fName.text = [NSString stringWithFormat:@"%@ %@", [kidsDic objectForKey:KID_FIRST_NAME], [kidsDic objectForKey:KID_LAST_NAME]];
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSLog(@"%@", kidsDic);
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, [kidsDic objectForKey:SCHOOL_IMAGE_NAME]];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
        {
            
            UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
            
           
            UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
            
            
            imageView.image = image;

        }

                /*
        
        fName.text = ;
        
        [fName setDelegate:self];
        [self.textfields addObject:fName];
        
        
        UITextField *lName =  (UITextField *)[cell.contentView viewWithTag:2];
        lName.text = [kidsDic objectForKey:KID_LAST_NAME];
        [lName setDelegate:self];
        [self.textfields addObject:lName];
        
        UITextField *gradeLevel =  (UITextField *)[cell.contentView viewWithTag:3];
        gradeLevel.text = [kidsDic objectForKey:KID_GRADE_LEVEL];
        [gradeLevel setDelegate:self];
        [self.textfields addObject:gradeLevel];
        
        UIButton *deleteButton = (UIButton *)[cell.contentView viewWithTag:4];
        UIButton *updateButton = (UIButton *)[cell.contentView viewWithTag:5];
        
        [deleteButton addTarget:self action:@selector(deletePressed:) forControlEvents:UIControlEventTouchDown];
        [updateButton addTarget:self action:@selector(updatePressed:) forControlEvents:UIControlEventTouchDown];
        
        deleteButton.tag = indexPath.row + 10;
        updateButton.tag = indexPath.row +100;
         
         */
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
        
        UIButton *addButton = (UIButton *)[cell.contentView viewWithTag:1];
        [addButton addTarget:self action:@selector(addPressed:) forControlEvents:UIControlEventTouchDown];
    }
        

    
    return cell;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    else
    {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    }
    
    if(!self.keyboardUP)
    {
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect rect = self.kidsTableView.bounds;
            CGPoint point = self.kidsTableView.center;
            point.y -= 108;
            rect.size.height -= 216;
            [self.kidsTableView setCenter:point];
            [self.kidsTableView setBounds:rect];
            
        }completion:^(BOOL finished) {
            //
        }];
        
        self.keyboardUP = true;
    }
    
    [self.kidsTableView scrollToRowAtIndexPath:[self.kidsTableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row != self.kidsArray.count)
    {
        
        self.kidDicToEdit = [self.kidsArray objectAtIndex:indexPath.row];
        self.addingNewKid = NO;
        [self performSegueWithIdentifier:SEGUE_TO_UPDATE_KID_VIEW sender:self];
    
        
    }
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_UPDATE_KID_VIEW])
    {
        UpdateKidViewController *UKVC = segue.destinationViewController;
        
        UKVC.addingNewKid = self.addingNewKid;
        UKVC.kidData = self.kidDicToEdit;
        UKVC.mainUserData = self.mainUserData;
       
    }
}



@end
