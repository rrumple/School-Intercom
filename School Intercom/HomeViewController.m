//
//  HomeViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *schoolNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *alertTableView;
@property (nonatomic, strong) NSArray *alertData;
@property (weak, nonatomic) IBOutlet UIImageView *adImageView;
@property (nonatomic, strong) NSDictionary *adData;

@end

@implementation HomeViewController

-(NSDictionary *)adData
{
    if(!_adData) _adData = [[NSDictionary alloc]init];
    return _adData;
}

-(NSArray *)alertData
{
    if(!_alertData) _alertData = [[NSArray alloc] init];
    return _alertData;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.alertTableView.dataSource = self;
    self.alertTableView.delegate = self;
    
    
    NSLog(@"HOME PAGE DATA RECIEVED: %@", self.mainUserData.appData);
    
    self.alertData = [self.mainUserData.appData objectForKey:ALERT_DATA];
    
    NSDictionary *schoolData = [[self.mainUserData.appData objectForKey:SCHOOL_DATA] objectAtIndex:0];
    
    
    self.schoolNameLabel.text = [NSString stringWithFormat:@"My %@ Alerts!",[schoolData objectForKey:SCHOOL_NAME]];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.alertData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"alertCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    UILabel *cellLabel = (UILabel *)[cell.contentView viewWithTag:2];
    
    cellLabel.text = [[self.alertData objectAtIndex:indexPath.row]objectForKey:ALERT_TEXT];
    
    UIImageView *cellImage = (UIImageView *)[cell.contentView viewWithTag:1];
    
    cellImage.image = [UIImage imageNamed:@"redAlert.png"];
    
    //[cell setBackgroundColor:self.accentColor];
    
    return cell;
}



@end
