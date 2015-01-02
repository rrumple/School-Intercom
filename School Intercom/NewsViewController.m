//
//  NewsViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "NewsViewController.h"

@interface NewsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *newsTableview;
@property (weak, nonatomic) IBOutlet UILabel *newsHeaderLabel;

@property (weak, nonatomic) IBOutlet UIButton *adImageButton;
@property (nonatomic, strong) NSDictionary *adData;
@property (nonatomic, strong) AdModel *adModel;
@property (weak, nonatomic) IBOutlet UIView *overlay1;
@property (weak, nonatomic) IBOutlet UIView *helpOverlay;

@end

@implementation NewsViewController

- (AdModel *)adModel
{
    if(!_adModel) _adModel = [[AdModel alloc]init];
    return _adModel;
}

-(NSDictionary *)adData
{
    if(!_adData) _adData = [[NSDictionary alloc]init];
    return _adData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.newsHeaderLabel.text = self.newsHeader;
    self.newsTableview.delegate = self;
    self.newsTableview.dataSource = self;
    
    NSLog(@"%@", self.newsHeaderLabel.font);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.newsHeaderLabel setFont:FONT_CHARCOAL_CY(17.0f)];

    
    [self getAdFromDatabase];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([self.mainUserData getTutorialStatusOfView:mv_News])
        [self showHelp];
}

- (void)showHelp
{
    self.helpOverlay.hidden = false;
    self.overlay1.hidden = false;
    
    [UIView animateWithDuration:1 animations:^{
        
        
        self.overlay1.alpha = 0.5;
        self.helpOverlay.alpha = 1.0;
        //self.dismissButton.alpha = 1.0;
        //self.help1.alpha = 1.0;
    }];
}

- (IBAction)hideHelpPressed
{
    [self.mainUserData turnOffTutorialForView:mv_News];
    [UIView animateWithDuration:.75 animations:^{
        self.overlay1.alpha = 0.0;
        self.helpOverlay.alpha = 0.0;
        //self.dismissButton.alpha = 1.0;
        //self.help1.alpha = 1.0;
        
    }completion:^(BOOL finished){
        self.overlay1.hidden = true;
        self.helpOverlay.hidden = true;
    }];
    
    
    
    
    
}

- (IBAction)adButtonclicked
{
    NSString *urlString;
    
    switch ([[self.adData objectForKey:AD_TYPE]intValue])
    {
        case 0:
        case 1:
        {
            urlString = [self.adData objectForKey:AD_URL_LINK];
        }
            break;
        case 2:
        {
            urlString = [NSString stringWithFormat:@"%@?id=%@&user=%@", AD_OFFER_LINK, [self.adData objectForKey:ID], self.userID];
        }
            break;
            
        default:
            break;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];

    
    dispatch_queue_t createQueue = dispatch_queue_create("updateAdClickCount", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adModel updateAdClickCountInDatabse:[self.adData objectForKey:ID]fromSchool:self.mainUserData.schoolIDselected];
        if ([dataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    NSLog(@"%@", tempDic);
                }
            });
            
        }
    });

}

- (void)loadAdImage
{
    NSString *fileName = [self.adData objectForKey:AD_IMAGE_NAME];
    
    NSString *baseImageURL = [NSString stringWithFormat:@"%@%@%@", AD_IMAGE_URL, AD_DIRECTORY, fileName];
    
    NSLog(@"%@", baseImageURL);
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("get Image", NULL);
    dispatch_async(downloadQueue, ^{
        
        
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:baseImageURL]];
        dispatch_async(dispatch_get_main_queue(),^{
            UIImage *image = [UIImage imageWithData:data];
            [self.adImageButton setImage:image forState:UIControlStateNormal];
            //[spinner stopAnimating];
            NSLog(@"%f, %f", image.size.width, image.size.height);
        });
        
        
    });
    
}

- (void)getAdFromDatabase
{
    
   
    dispatch_queue_t createQueue = dispatch_queue_create("getLocalAd", NULL);
    dispatch_async(createQueue, ^{
        NSArray *adDataArray;
        adDataArray = [self.adModel getAdFromDatabase:self.schoolID];
        
        if ([adDataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [[adDataArray objectAtIndex:0] objectForKey:@"adData"];
                
                self.adData = tempDic;
                
                if(self.adData != (id)[NSNull null])
                    [self loadAdImage];
                else
                    self.adImageButton.enabled = false;
                
            });
            
        }
    });
    
}

- (IBAction)menuPressed
{
    if([self.delegate respondsToSelector:@selector(snapshotOfViewAsImage:)])
    {
        [self.delegate snapshotOfViewAsImage:[UIView captureView:self.view]];
        
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}
- (void)loadNewsImageAtIndex:(NSIndexPath *)path forImage:(UIImageView *)imageView withActivityIndicator:(UIActivityIndicatorView *)spinner
{
    
    NSString *fileName = [[self.newsData objectAtIndex:path.row ] objectForKey:NEWS_IMAGE_NAME];
    
    NSString *baseImageURL = [NEWS_IMAGE_URL stringByAppendingString:fileName];
    
    NSLog(@"%@", baseImageURL);
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("get Image", NULL);
    dispatch_async(downloadQueue, ^{
        
        
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:baseImageURL]];
        dispatch_async(dispatch_get_main_queue(),^{
            UIImage *image = [UIImage imageWithData:data];
            [imageView setImage:image];
            [spinner stopAnimating];
            NSLog(@"%f, %f", image.size.width, image.size.height);
        });
        
        
    });
    
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
    if(self.newsData != (id)[NSNull null])
        return [self.newsData count];
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    NSDictionary *newsDic = [self.newsData objectAtIndex:indexPath.row];
    
    NSString *imageName = [newsDic objectForKey:NEWS_IMAGE_NAME];
    
    if(imageName != (id)[NSNull null])
        height = 115.0;
    else
        height = 68.0;
    
    return height;
    
    
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 == 0)
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        [cell setBackgroundColor:self.accentColor];
    }
    
}
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *newsDic = [self.newsData objectAtIndex:indexPath.row];
    
    
    
    static NSString *CellIdentifier = @"newsCellWithImage";
    static NSString *CellIdentifier2 = @"newsCellNoImage";
    
    NSString *cellid = nil;
    
    
    NSString *imageName = [newsDic objectForKey:NEWS_IMAGE_NAME];
    UITableViewCell *cell;
    if(imageName != (id)[NSNull null])
    {
        cellid = CellIdentifier;
        cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
        
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell.contentView viewWithTag:4];
        
        [self loadNewsImageAtIndex:indexPath forImage:imageView withActivityIndicator:spinner];
    }
    else
    {
        cellid = CellIdentifier2;
        cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
        
    }
    
    
    
    
    UILabel *cellLabel = (UILabel *)[cell.contentView viewWithTag:2];
    
    cellLabel.text = [newsDic objectForKey:NEWS_TITLE];
    
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:3];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:[newsDic objectForKey:NEWS_DATE]];
    
    [dateFormatter setDateFormat:@"hh:mma MMM-dd"];
    
    NSString *convertedDate =[dateFormatter stringFromDate:date];
    
    dateLabel.text = convertedDate;
    
    //UIImageView *cellImage = (UIImageView *)[cell.contentView viewWithTag:1];
    
    //cellImage.image = [UIImage imageNamed:@"redAlert.png"];
    
    
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
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    if([segue.identifier isEqualToString:SEGUE_TO_NEWS_DETAIL_VIEW])
    {
        
        NSIndexPath *index = [self.newsTableview indexPathForSelectedRow];
        
        NewsDetailViewController *NDVC = segue.destinationViewController;
        NDVC.newsDetailData = [self.newsData objectAtIndex:index.row];
       
    }
     
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:SEGUE_TO_NEWS_DETAIL_VIEW sender:self];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
