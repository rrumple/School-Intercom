//
//  ManageNewsViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 2/1/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "ManageNewsViewController.h"
#import "ManagePostTableViewController.h"

@interface ManageNewsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic, strong) NSArray *newsData;
@property (nonatomic, strong) NSDictionary *newsPostSelected;
@property (nonatomic) BOOL isNewPost;
@property (weak, nonatomic) IBOutlet UITableView *newsTableView;

@end

@implementation ManageNewsViewController

- (NSArray *)newsData
{
    if (!_newsData) _newsData = [[NSArray alloc]init];
    return _newsData;
}

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)getUserNewsPostsFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("getNewsPosts", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData getNewsPostsforUser:self.mainUserData.userID];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.newsData = databaseData;
                [self.newsTableView reloadData];
                
            });
            
        }
    });
    
}

- (void)deleteNewsFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("deleteNewsPost", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData deleteNews:[self.newsPostSelected objectForKey:ID]];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LOAD_DATA" object:nil userInfo:nil];
                
            });
            
        }
    });
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
   
    [self getUserNewsPostsFromDatabase];
    
    self.newsPostSelected = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isNewPost = false;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)addNewsButtonPressed
{
    self.isNewPost = true;
    [self performSegueWithIdentifier:SEGUE_TO_MANAGE_POST sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_MANAGE_POST])
    {
        ManagePostTableViewController *MPTVC = segue.destinationViewController;
        MPTVC.mainUserData = self.mainUserData;
        
        
        if(self.isNewPost)
        {
            self.isNewPost = false;
            MPTVC.isNewPost = true;
        }
        else
        {
            MPTVC.postData = self.newsPostSelected;
            MPTVC.isNewPost = false;
            
        }
        
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.newsData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsCell" forIndexPath:indexPath];
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[[self.newsData objectAtIndex:indexPath.row] objectForKey:NEWS_TITLE]];
    
    NSLog(@"%@", [[self.newsData objectAtIndex:indexPath.row]objectForKey:NEWS_DATE]);
    
    NSArray *startTimeArray = [HelperMethods getDateArrayFromString:[[self.newsData objectAtIndex:indexPath.row ] objectForKey:NEWS_DATE]];
    startTimeArray = [HelperMethods ConvertHourUsingDateArray:startTimeArray];
    
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@, %@ - %@", [HelperMethods getMonthWithInt:[startTimeArray[1] integerValue]shortName:NO], startTimeArray[2], startTimeArray[0], [self.mainUserData getClassName:[[self.newsData objectAtIndex:indexPath.row]objectForKey:@"classID"]]];
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.isNewPost = false;
    self.newsPostSelected = [self.newsData objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SEGUE_TO_MANAGE_POST sender:self];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        self.newsPostSelected = [self.newsData objectAtIndex:indexPath.row];
        NSMutableArray *array = [self.newsData mutableCopy];
        [array removeObjectAtIndex:indexPath.row];
        self.newsData = array;
        [self deleteNewsFromDatabase];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


@end
