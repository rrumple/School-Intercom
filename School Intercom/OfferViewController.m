//
//  OfferViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 2/7/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "OfferViewController.h"
#import "OfferModel.h"
#import "SchoolIntercomIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "IntroModel.h"

@interface OfferViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_products;
}

@property (weak, nonatomic) IBOutlet UITableView *offerTableView;
@property (nonatomic, strong) NSArray *offerData;
@property (nonatomic, strong) OfferModel *offerModel;
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

@implementation OfferViewController

- (IntroModel *)introData
{
    if (!_introData) _introData = [[IntroModel alloc]init];
    return  _introData;
}

-(OfferModel *)offerModel
{
    if(!_offerModel) _offerModel = [[OfferModel alloc]init];
    return _offerModel;
}

-(void)getOffersFromDatabase
{
    _products = nil;
    
    [[SchoolIntercomIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products)
     {
         if(success)
         {
             _products = products;
             
         }
         
     }];
    
    dispatch_queue_t createQueue = dispatch_queue_create("getOffers", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.offerModel getOffersForSchool:self.mainUserData.schoolIDselected];
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
                    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                    
                    if(!self.mainUserData.isDemoInUse)
                        [tempArray addObject:@{}];
                    
                    [tempArray addObjectsFromArray:[tempDic objectForKey:@"fundraiserData"]];
                    
                    self.offerData = tempArray;
                    
                    [self.offerTableView reloadData];
                    
                }
            });
            
        }
    });

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
        
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Offer_Screen"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restorePurchaseFailed) name:IAPHelperRestorePurchaseFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchaseFailed) name:IAPHelperProductPurchaseFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productRestored:) name:IAPHelperProductRestoredPurchaseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreComplete) name:IAPHelperProductRestoreCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreComplete:) name:IAPHelperProductRestoreCompletedWithNumber object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPushAlert:) name:@"DisplayAlert" object:nil];
    
    
}

- (void)showPushAlert:(NSNotification *)notification
{
    NSDictionary *data = [notification userInfo];
    
    [HelperMethods CreateAndDisplayOverHeadAlertInView:self.view withMessage:[data objectForKey:@"message"] andSchoolID:[data objectForKey:SCHOOL_ID]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getOffersFromDatabase];
    
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
                    self.mainUserData.hasPurchased = true;

                    [self.offerTableView reloadData];
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
    //NSLog(@"%@ restored", productIdentifier);
    
    for(NSDictionary *offerDic in self.offerData)
    {
        if([[offerDic objectForKey:ID] isEqualToString:productIdentifier])
        {
            self.productSelectedForPurchase = offerDic;
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
    
    
    NSString *offerName;
    NSString *schoolName;
    
    for(NSDictionary * tempDic in self.offerData)
    {
        if([[tempDic objectForKey:ID] isEqualToString:productIdentifier])
        {
            offerName = [tempDic objectForKey:OFFER_TITLE];
            schoolName = [self.mainUserData getSchoolNameFromID:self.mainUserData.schoolIDselected];
        }
            
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Offer Purchased"
                                                          action:@"In_App_Purchase_completed"
                                                           label:[NSString stringWithFormat:@"%@ - %@", offerName, schoolName]
                                                           value:@1] build]];
    
    [self.loadingIndicatorView setHidden:true];
    [self.loadingIndicatorBackgroundView setHidden:true];
    [self.loadingActivityIndicator stopAnimating];
    if([[SchoolIntercomIAPHelper sharedInstance] isProductPurchased:productIdentifier])
    {
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
    CGPoint rootViewPoint = [[sender superview]convertPoint:center toView:self.offerTableView];
    self.currentIndexPath = [self.offerTableView indexPathForRowAtPoint:rootViewPoint];
    
    if([[[self.offerData objectAtIndex:self.currentIndexPath.section] objectForKey:OFFER_IS_IN_APP_PURCHASE] boolValue])
    {
        if([self.mainUserData.accountType intValue] == utParent || [self.mainUserData.accountType intValue] == utGrandparent)
        {
            self.currentBuyButtonSelected = sender;
          
                self.productSelectedForPurchase = [self.offerData objectAtIndex:self.currentIndexPath.section];
                self.loadingActivityIndicatorLabel.text = @"Purchasing...";
                [self.loadingIndicatorView setHidden:false];
                [self.loadingIndicatorBackgroundView setHidden:false];
                [self.loadingActivityIndicator startAnimating];
            [self.currentBuyButtonSelected setEnabled:false];
                [self buyProduct];
            
 
            
        
        }
    }
    else
    {
        NSMutableDictionary *articleParams = [[NSMutableDictionary alloc]init];
        

       
            [articleParams setValue:[[self.offerData objectAtIndex:self.currentIndexPath.section] objectForKey:OFFER_TITLE] forKey:OFFER_TITLE];
         [articleParams setValue:[[self.offerData objectAtIndex:self.currentIndexPath.section] objectForKey:OFFER_BUY_BUTTON_LINK] forKey:OFFER_BUY_BUTTON_LINK];
            [articleParams setValue:[self.mainUserData getSchoolNameFromID:self.mainUserData.schoolIDselected] forKey:SCHOOL_NAME];
        
        
        //[Flurry logEvent:@"OFFER_LINK_CLICKED" withParameters:articleParams];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Offer Link"
                                                              action:@"Offer_Link_Clicked"
                                                               label:[NSString stringWithFormat:@"%@ - %@", [[self.offerData objectAtIndex:self.currentIndexPath.section] objectForKey:OFFER_TITLE], [self.mainUserData getSchoolNameFromID:self.mainUserData.schoolIDselected]]
                                                               value:@1] build]];
        
        

        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[[self.offerData objectAtIndex:self.currentIndexPath.section] objectForKey:OFFER_BUY_BUTTON_LINK]]];
    }
    
    

}

- (IBAction)moreInfoButtonPressed:(UIButton *)sender
{
    CGPoint center = [sender center];
    CGPoint rootViewPoint = [[sender superview]convertPoint:center toView:self.offerTableView];
    self.currentIndexPath = [self.offerTableView indexPathForRowAtPoint:rootViewPoint];
    
     [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[[self.offerData objectAtIndex:self.currentIndexPath.section] objectForKey:OFFER_MORE_INFO_LINK]]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)restorePurchasesButtonPressed
{
    if([self.mainUserData.accountType intValue] == utParent || [self.mainUserData.accountType intValue] == utGrandparent)
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
    return [self.offerData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && !self.mainUserData.isDemoInUse)
        return 44.0;
    else
    {
        if([[[self.offerData objectAtIndex:indexPath.section] objectForKey:OFFER_DETAIL_TEXT] length] / 42.0 < 3.0)
        {
            return 163.0;
        }
        else if([[[self.offerData objectAtIndex:indexPath.section] objectForKey:OFFER_DETAIL_TEXT] length] / 42.0 < 6.0)
        {
            return 220.0;
        }
        else if([[[self.offerData objectAtIndex:indexPath.section] objectForKey:OFFER_DETAIL_TEXT] length] / 42.0 < 8.0)
        {
            return 245.0;
        }
        else
            return 273.0;

    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSDictionary *offerDic = [self.offerData objectAtIndex:indexPath.section];
    
    static NSString *CellIdentifier = @"offerCell";
    static NSString *cellIdentifier2 = @"restorePurchaseCell";
   
    

    UITableViewCell *cell;
    
    if(indexPath.section == 0 && !self.mainUserData.isDemoInUse)
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2 forIndexPath:indexPath];
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        
        
        UILabel *mainTitle = (UILabel *)[cell.contentView viewWithTag:2];
        UIButton *buyButton = (UIButton *)[cell.contentView viewWithTag:3];
        UILabel *detailText = (UILabel *)[cell.contentView viewWithTag:4];
        UIButton *moreInfoButton = (UIButton *)[cell.contentView viewWithTag:5];
        
        mainTitle.text = [offerDic objectForKey:OFFER_TITLE];
        
        if([[SchoolIntercomIAPHelper sharedInstance] isProductPurchased:[offerDic objectForKey:ID]] && self.mainUserData.hasPurchased)
        {
            if(self.mainUserData.hasPurchased)
                [buyButton setEnabled:NO];
            else
            {
                UIAlertView * restoredAlert = [[UIAlertView alloc]initWithTitle:@"Purchase Error!" message:[NSString stringWithFormat:@"There was an error updating the transaction in our database, please click Restore Purchases to complete the transaction"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                restoredAlert.tag = zAlertProductPurchaseError;
                [restoredAlert show];

            }
        }
        else
        {
            if([[offerDic objectForKey:OFFER_IS_IN_APP_PURCHASE] boolValue])
            {
                if([self.mainUserData.accountType intValue] > 0 && [self.mainUserData.accountType intValue] < 8)
                {
                    [buyButton setEnabled:NO];
                    [buyButton setTitle:@"Granted" forState:UIControlStateDisabled];
                }
                else
                {
                    [buyButton setTitle:[NSString stringWithFormat:@"Buy $%@", [offerDic objectForKey:OFFER_PRICE]] forState:UIControlStateNormal];
                }
            }
            else
            {
                [buyButton setTitle:[offerDic objectForKey:OFFER_BUY_BUTTON_TEXT] forState:UIControlStateNormal];
            }
            
        }
        
        detailText.text = [offerDic objectForKey:OFFER_DETAIL_TEXT];
        if([offerDic objectForKey:OFFER_MORE_INFO_LINK] != (id)[NSNull null])
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
