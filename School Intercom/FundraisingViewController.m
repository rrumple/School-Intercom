//
//  FundraisingViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 2/7/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "FundraisingViewController.h"
#import "FundraiserModel.h"
#import "SchoolIntercomIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "IntroModel.h"

@interface FundraisingViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_products;
}

@property (weak, nonatomic) IBOutlet UITableView *fundraisingTableView;
@property (nonatomic, strong) NSArray *fundraiserData;
@property (nonatomic, strong) FundraiserModel *fundraiserModel;
@property (nonatomic, strong) NSDictionary *productSelectedForPurchase;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (weak, nonatomic) IBOutlet UILabel *loadingActivityIndicatorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;
@property (nonatomic, strong) UIAlertView *productPurchasedFailedAlert;
@property (nonatomic, strong) IntroModel *introData;
@property (nonatomic, strong) UIButton *currentBuyButtonSelected;
@property (weak, nonatomic) IBOutlet UIView *loadingIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *loadingIndicatorBackgroundView;
@property (nonatomic, strong) UIAlertView *purchseSuccess;
@property (nonatomic) NSUInteger numberOfSchoolsRestored;
@end

@implementation FundraisingViewController

- (IntroModel *)introData
{
    if (!_introData) _introData = [[IntroModel alloc]init];
    return  _introData;
}

-(FundraiserModel *)fundraiserModel
{
    if(!_fundraiserModel) _fundraiserModel = [[FundraiserModel alloc]init];
    return _fundraiserModel;
}

-(void)getFundraisersFromDatabase
{
    _products = nil;
    
    [[SchoolIntercomIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products)
     {
         if(success)
         {
             _products = products;
             
         }
         
     }];
    
    dispatch_queue_t createQueue = dispatch_queue_create("getFundraisers", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.fundraiserModel getFundraisersForSchool:self.mainUserData.schoolIDselected];
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
                    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithObjects:@{}, nil];
                    
                    [tempArray addObjectsFromArray:[tempDic objectForKey:@"fundraiserData"]];
                    
                    self.fundraiserData = tempArray;
                    
                    [self.fundraisingTableView reloadData];
                    
                }
            });
            
        }
    });

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restorePurchaseFailed) name:IAPHelperRestorePurchaseFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchaseFailed) name:IAPHelperProductPurchaseFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productRestored:) name:IAPHelperProductRestoredPurchaseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreComplete) name:IAPHelperProductRestoreCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreComplete:) name:IAPHelperProductRestoreCompletedWithNumber object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getFundraisersFromDatabase];
    
    [self.loadingIndicatorBackgroundView.layer setCornerRadius:30.0f];
    [self.loadingIndicatorBackgroundView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.loadingIndicatorBackgroundView.layer setBorderWidth:1.5f];
    [self.loadingIndicatorBackgroundView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.loadingIndicatorBackgroundView.layer setShadowOpacity:0.8];
    [self.loadingIndicatorBackgroundView.layer setShadowRadius:3.0];
    [self.loadingIndicatorBackgroundView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    // Do any additional setup after loading the view.
}

- (void)showRestorePurchasedFailedAlert
{
    
    self.productPurchasedFailedAlert = [[UIAlertView alloc]initWithTitle:@"Restore Failed" message:@"Unable to restore purchase, Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [self.productPurchasedFailedAlert show];
}

- (void)showProductPurchasedFailedAlert
{
    
    self.productPurchasedFailedAlert = [[UIAlertView alloc]initWithTitle:@"Purchased Failed" message:@"Unable to complete purchase, Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [self.productPurchasedFailedAlert show];
}

- (void)updateHasPurchasedInDatabaseWithTransactionID:(NSString *)transactionID
{
    dispatch_queue_t createQueue = dispatch_queue_create("updateHasPurchased", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.introData updateHasPurchasedinUserSchoolTable:self.mainUserData.userID ofSchool:self.mainUserData.schoolIDselected hasPurchasedBOOL:[[NSUserDefaults standardUserDefaults]objectForKey:USER_HAS_PURCHASED]withTransactionID:transactionID];
        
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
                    [self.fundraisingTableView reloadData];
                }
            });
            
        }
    });
    
}

- (void)restoreComplete:(NSNotification *)notification
{
    [self restoreComplete];
}

- (void)restoreComplete
{
    [self.loadingIndicatorView setHidden:true];
    [self.loadingIndicatorBackgroundView setHidden:true];
    [self.loadingActivityIndicator stopAnimating];
    if (self.numberOfSchoolsRestored == 0)
    {
        UIAlertView *restoreFailed = [[UIAlertView alloc]initWithTitle:@"Restore Complete" message:@"All purchases have been restored or the Apple ID used is incorrect." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [restoreFailed show];
        
        
    }
    else
    {
        UIAlertView *restoreComplete = [[UIAlertView alloc]initWithTitle:@"Restore Complete" message:@"You purchases have been restored." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [restoreComplete show];
    }
    
}


- (void)productRestored:(NSNotification *)notification
{
    self.numberOfSchoolsRestored++;
    
    SKPaymentTransaction *transaction = notification.object;
    NSString *productIdentifier = transaction.payment.productIdentifier;
    //NSString *transactionIdentifier = transaction.transactionIdentifier;
    NSLog(@"%@ restored", productIdentifier);
    
    for(NSDictionary *fundraiserDic in self.fundraiserData)
    {
        if([[fundraiserDic objectForKey:ID] isEqualToString:productIdentifier])
        {
            self.productSelectedForPurchase = fundraiserDic;
            break;
        }
    }
    
    self.mainUserData.hasPurchased = true;
    
    [self updateHasPurchasedInDatabaseWithTransactionID:transaction.transactionIdentifier];
    
    /*NSString *schoolName = [self.mainUserData getSchoolNameFromID:notification.object];
     
     UIAlertView * restoredAlert = [[UIAlertView alloc]initWithTitle:@"Access Restored" message:[NSString stringWithFormat:@"Your access to %@, has been restored", schoolName] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
     restoredAlert.tag = zAlertProductedRestored;
     [restoredAlert show];
     */
}


- (void)restoreAccount
{
    self.numberOfSchoolsRestored = 0;
    [[SchoolIntercomIAPHelper sharedInstance] restoreCompletedTransactions];
    
}

- (void)restorePurchaseFailed
{
    //self.isPurchaseInProgress = false;
    self.loadingIndicatorView.hidden = true;
    self.loadingIndicatorBackgroundView.hidden = true;
    self.loadingActivityIndicatorLabel.text = @"Purchasing...";
    
    [self.loadingActivityIndicator stopAnimating];
    [self showRestorePurchasedFailedAlert];
}

- (void)productPurchaseFailed
{
    //self.isPurchaseInProgress = false;
    self.loadingIndicatorView.hidden = true;
    self.loadingIndicatorBackgroundView.hidden = true;
    self.loadingActivityIndicatorLabel.text = @"Purchasing...";
    
    [self.loadingActivityIndicator stopAnimating];
    [self showProductPurchasedFailedAlert];
}


- (void)productPurchased:(NSNotification *)notification
{
    
    //self.isPurchaseInProgress = false;
    SKPaymentTransaction *transaction = notification.object;
    NSString *productIdentifier = transaction.payment.productIdentifier;
    
    NSMutableDictionary *articleParams = [[NSMutableDictionary alloc]init];
    
    for(NSDictionary * tempDic in self.fundraiserData)
    {
        if([[tempDic objectForKey:ID] isEqualToString:productIdentifier])
        {
            [articleParams setValue:[tempDic objectForKey:FUNDRAISER_TITLE] forKey:FUNDRAISER_TITLE];
            [articleParams setValue:self.mainUserData.schoolIDselected forKey:SCHOOL_ID];
        }
            
    }
    [Flurry logEvent:@"PRODUCT_PURCHASED" withParameters:articleParams];
    
    [self.loadingIndicatorView setHidden:true];
    [self.loadingIndicatorBackgroundView setHidden:true];
    [self.loadingActivityIndicator stopAnimating];
    if([[SchoolIntercomIAPHelper sharedInstance] isProductPurchased:productIdentifier])
    {
        self.mainUserData.hasPurchased = true;
        
        [self updateHasPurchasedInDatabaseWithTransactionID:transaction.transactionIdentifier];
    }
}


- (void)buyProduct
{
    
    if(_products)
    {
        
        for (SKProduct * product in _products)
        {
            if([product.productIdentifier isEqualToString:[self.productSelectedForPurchase objectForKey:ID]])
            {
                //self.isPurchaseInProgress = true;
                [[SchoolIntercomIAPHelper sharedInstance] buyProduct:product];
                //break;
            }
        }
    }
    else
    {
        //show error message to try again later
    }
}


- (IBAction)buyButtonPressed:(UIButton *)sender
{
    CGPoint center = [sender center];
    CGPoint rootViewPoint = [[sender superview]convertPoint:center toView:self.fundraisingTableView];
    self.currentIndexPath = [self.fundraisingTableView indexPathForRowAtPoint:rootViewPoint];
    
    if([[[self.fundraiserData objectAtIndex:self.currentIndexPath.section] objectForKey:FUNDRAISER_IS_IN_APP_PURCHASE] boolValue])
    {
        if([self.mainUserData.accountType intValue] == 0)
        {
            self.currentBuyButtonSelected = sender;
            self.productSelectedForPurchase = [self.fundraiserData objectAtIndex:self.currentIndexPath.section];
            self.loadingActivityIndicatorLabel.text = @"Purchasing...";
            [self.loadingIndicatorView setHidden:false];
            [self.loadingIndicatorBackgroundView setHidden:false];
            [self.loadingActivityIndicator startAnimating];
            [self buyProduct];
        }
    }
    else
    {
        NSMutableDictionary *articleParams = [[NSMutableDictionary alloc]init];
        

       
            [articleParams setValue:[[self.fundraiserData objectAtIndex:self.currentIndexPath.section] objectForKey:FUNDRAISER_TITLE] forKey:FUNDRAISER_TITLE];
         [articleParams setValue:[[self.fundraiserData objectAtIndex:self.currentIndexPath.section] objectForKey:FUNDRAISER_BUY_BUTTON_LINK] forKey:FUNDRAISER_BUY_BUTTON_LINK];
            [articleParams setValue:self.mainUserData.schoolIDselected forKey:SCHOOL_ID];
        
        
        [Flurry logEvent:@"FUNDRAISING_LINK_CLICKED" withParameters:articleParams];

        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[[self.fundraiserData objectAtIndex:self.currentIndexPath.section] objectForKey:FUNDRAISER_BUY_BUTTON_LINK]]];
    }
    
    

}

- (IBAction)moreInfoButtonPressed:(UIButton *)sender
{
    CGPoint center = [sender center];
    CGPoint rootViewPoint = [[sender superview]convertPoint:center toView:self.fundraisingTableView];
    self.currentIndexPath = [self.fundraisingTableView indexPathForRowAtPoint:rootViewPoint];
    
     [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[[self.fundraiserData objectAtIndex:self.currentIndexPath.section] objectForKey:FUNDRAISER_MORE_INFO_LINK]]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)restorePurchasesButtonPressed
{
    if([self.mainUserData.accountType intValue] == 0)
    {
        [self.loadingIndicatorView setHidden:false];
        [self.loadingIndicatorBackgroundView setHidden:false];
        [self.loadingActivityIndicator startAnimating];
        self.loadingActivityIndicatorLabel.text = @"Restoring...";
        [self restoreAccount];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)backButtonPressed
{
    if([self.delegate respondsToSelector:@selector(snapshotOfViewAsImage:)])
    {
        [self.delegate snapshotOfViewAsImage:[UIView captureView:self.view]];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];

}



-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.cornerRadius = 12;
    cell.layer.masksToBounds = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.fundraiserData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return 44.0;
    else
    {
        if([[[self.fundraiserData objectAtIndex:indexPath.section] objectForKey:FUNDRAISER_DETAIL_TEXT] length] / 42.0 < 3.0)
        {
            return 163.0;
        }
        else if([[[self.fundraiserData objectAtIndex:indexPath.section] objectForKey:FUNDRAISER_DETAIL_TEXT] length] / 42.0 < 6.0)
        {
            return 220.0;
        }
        else if([[[self.fundraiserData objectAtIndex:indexPath.section] objectForKey:FUNDRAISER_DETAIL_TEXT] length] / 42.0 < 8.0)
        {
            return 245.0;
        }
        else
            return 273.0;

    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSDictionary *fundraiserDic = [self.fundraiserData objectAtIndex:indexPath.section];
    
    static NSString *CellIdentifier = @"fundraisingCell";
    static NSString *cellIdentifier2 = @"restorePurchaseCell";
   
    

    UITableViewCell *cell;
    
    if(indexPath.section == 0)
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2 forIndexPath:indexPath];
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
   
    
        UILabel *mainTitle = (UILabel *)[cell.contentView viewWithTag:2];
        UIButton *buyButton = (UIButton *)[cell.contentView viewWithTag:3];
        UILabel *detailText = (UILabel *)[cell.contentView viewWithTag:4];
        UIButton *moreInfoButton = (UIButton *)[cell.contentView viewWithTag:5];
        
        mainTitle.text = [fundraiserDic objectForKey:FUNDRAISER_TITLE];
        
        if([[SchoolIntercomIAPHelper sharedInstance] isProductPurchased:[fundraiserDic objectForKey:ID]])
        {
            [buyButton setEnabled:NO];
        }
        else
        {
            if([[fundraiserDic objectForKey:FUNDRAISER_IS_IN_APP_PURCHASE] boolValue])
            {
                if([self.mainUserData.accountType intValue] > 0)
                {
                    [buyButton setEnabled:NO];
                }
                else
                {
                    [buyButton setTitle:[NSString stringWithFormat:@"Buy $%@", [fundraiserDic objectForKey:FUNDRAISER_PRICE]] forState:UIControlStateNormal];
                }
            }
            else
            {
                [buyButton setTitle:[fundraiserDic objectForKey:FUNDRAISER_BUY_BUTTON_TEXT] forState:UIControlStateNormal];
            }

        }
            
            detailText.text = [fundraiserDic objectForKey:FUNDRAISER_DETAIL_TEXT];
        if([fundraiserDic objectForKey:FUNDRAISER_MORE_INFO_LINK] != (id)[NSNull null])
        {
            [moreInfoButton addTarget:self action:@selector(moreInfoButtonPressed:) forControlEvents:UIControlEventTouchDown];
            [moreInfoButton setHidden:false];
        }
        else
        {
            [moreInfoButton setHidden:true];
        }
        
            
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
        
            
            NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, [self.mainUserData.schoolData objectForKey:SCHOOL_IMAGE_NAME]];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
            {
                
                UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
                
                
                UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
                
                
                imageView.image = image;
                
            }

    }
    
  
    
    
    
    
    
    
    return cell;
}



@end
