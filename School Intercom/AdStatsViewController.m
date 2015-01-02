//
//  AdStatsViewController.mhttp://dab1nmslvvntp.cloudfront.net/wp-content/uploads/2011/09/Graph03.png
//  School Intercom
//
//  Created by Randall Rumple on 12/14/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//


//queryType 1 = Corp Query
//queryType 2 = schools within a corp Query
//queryType 3 = ads within a school Query
//querytype 4 = a single ads stats for all schools it belongs to

#import "AdStatsViewController.h"
#import "AdminModel.h"

@interface AdStatsViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic, strong) NSString *queryType;
@property (nonatomic, strong) NSString *idToQuery;
@property (nonatomic, strong) NSString *previousIdToQuery;
@property (weak, nonatomic) IBOutlet UITextField *groupTextField;
@property (nonatomic, strong) NSArray *groupPickerValues;
@property (nonatomic, strong) NSArray *alertGroupsData;
@property (nonatomic, strong) NSDictionary *groupSelected;
@property (nonatomic, strong) NSArray *graphData;
@property (weak, nonatomic) IBOutlet UIButton *graphBackButton;
@property (weak, nonatomic) IBOutlet UIButton *graphReloadButton;
@property (nonatomic, strong) NSDictionary *schoolSelected;
@property (weak, nonatomic) IBOutlet UIButton *emailGraphButton;
@property (nonatomic) int chartType;
@property (nonatomic) int barType;
@property (nonatomic) NSUInteger index;


@end

@implementation AdStatsViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

-(UIPickerView *)createPickerWithTag:(NSInteger)tag
{
    UIPickerView *pickerView = [[UIPickerView alloc]init];
    pickerView.tag = tag;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    
    
    
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickerViewTapped)];
    //tapGR.cancelsTouchesInView = NO;
    
    [tapGR setNumberOfTapsRequired:1];
    
    [tapGR setDelegate:self];
    [pickerView addGestureRecognizer:tapGR];
    
    return pickerView;
}

- (void)getAdStatsFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("ads", NULL);
    dispatch_async(createQueue, ^{
        NSArray *adStatsDataArray;
        adStatsDataArray = [self.adminData getAdStats:self.idToQuery ofType:self.queryType withSchoolID:[self.schoolSelected objectForKey:SCHOOL_ID]];
        
        if (adStatsDataArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"%@", adStatsDataArray);
                
                [self.graphView.impressions removeAllObjects];
                [self.graphView.clicks removeAllObjects];
                [self.graphView.labels removeAllObjects];
                [self.graphView.lineData removeAllObjects];
                [[self.graphView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];

                if(self.chartType == 1)
                {
                    for(NSDictionary *tempDict in [[adStatsDataArray objectAtIndex:0] objectForKey:@"data"])
                    {
                        
                        [self.graphView.impressions addObject:[tempDict objectForKey:@"impCount"]];
                        [self.graphView.clicks addObject:[tempDict objectForKey:@"clickCount"]];
                        [self.graphView.labels addObject:[tempDict objectForKey:@"label"]];
                        self.graphView.queryType = self.queryType;
                        switch ([self.queryType intValue])
                        {
                            case 1: self.graphView.titleAddOn = [tempDict objectForKey:@"label"];
                                break;
                            case 2: self.schoolSelected = [[NSDictionary alloc]initWithObjectsAndKeys:[tempDict objectForKey:ID],SCHOOL_ID,[tempDict objectForKey:@"label" ],@"label", nil];
                                self.graphView.titleAddOn = self.groupTextField.text;
                                break;
                            case 3:
                            case 4:
                                for (NSDictionary *tempDic in self.graphData)
                                {
                                    if([[tempDic objectForKey:ID]isEqualToString:self.idToQuery])
                                    {
                                        self.graphView.titleAddOn = [tempDic objectForKey:@"label"];
                                        break;
                                    }
                                }
                                break;
                                
                                
                                
                        }
                        
                        
                        
                    }
                    
                    self.graphData = [[adStatsDataArray objectAtIndex:0]objectForKey:@"data"];
                    self.graphView.kNumberOfBars = [[[adStatsDataArray objectAtIndex:0]objectForKey:@"data"] count];
                    self.graphView.chartType = 1;
                    


                }
                else if(self.chartType == 2)
                {
                    self.graphBackButton.hidden = false;
                    self.graphView.chartType = 2;
                    for(NSDictionary *tempDict in [[adStatsDataArray objectAtIndex:0] objectForKey:@"data"])
                    {
                        
                        if(self.barType == 2)
                        {
                            [self.graphView.lineData addObject:[tempDict objectForKey:@"clickCount"]];

                        }
                        else if(self.barType == 1)
                            [self.graphView.lineData addObject:[tempDict objectForKey:@"impCount"]];
                        
                        
                        [self.graphView.labels addObject:[tempDict objectForKey:@"statDate"]];
                        self.graphView.queryType = self.queryType;
                        
                        
                        switch ([self.queryType intValue])
                        {
                            case 6: self.graphView.titleAddOn = [[self.graphData objectAtIndex:self.index]objectForKey:@"label"];
                                break;
                            case 7:
                                
                                self.graphView.titleAddOn = [NSString stringWithFormat:@"%@ Campaign at %@", [[self.graphData objectAtIndex:self.index] objectForKey:@"label"],[self.schoolSelected objectForKey:@"label"]];
                                break;
                                
                                
                        }
                        
                        
                        
                    }

                    
                }
                
                [self.graphView setNeedsDisplay];
                
            });
            
        }
    });

}

- (void)makeSecondaryRequestFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("second_groups", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData getSecondaryAlertGroupsFromDatabase:self.idToQuery andQueryType:self.queryType];
        
        if (dataArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *tempDic = [dataArray objectAtIndex:0];
                    
                    if([[tempDic objectForKey:@"error"] boolValue])
                    {
                        [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                        
                    }
                    else
                    {
                        
                        
                        UIPickerView *tempPicker;
                        
                        self.groupPickerValues = [tempDic objectForKey:DATA];
                        
                        tempPicker = (UIPickerView *)self.groupTextField.inputView;
                        
                        
                        
                        [tempPicker reloadAllComponents];
                        [tempPicker selectRow:0 inComponent:0 animated:NO];
                        
                        
                    }
                });
                
                
                
                
                
            });
            
        }
    });
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.chartType = 1;
    self.queryType = [NSString stringWithFormat:@"%i", quGetAllCorps];
    self.idToQuery = @"";
    self.schoolSelected = [[NSDictionary alloc]initWithObjectsAndKeys:@"",SCHOOL_ID,@"", @"label", nil];

    [self makeSecondaryRequestFromDatabase];
    
    
    self.graphView.delegate = self;
    self.graphView.chartType = 1;
    self.scrollView.contentSize = CGSizeMake(self.graphView.frame.size.width, self.graphView.frame.size.height);
    
    self.groupTextField.inputView = [self createPickerWithTag:zPickerGroup];
   // NSLog(@"%f - %f", self.scrollView.contentSize.height, self.scrollView.contentSize.width);
    //self.graphView.impressions = @[@"150", @"375", @"550", @"400", @"802", @"533"];
   // self.graphView.clicks = @[@"100", @"250", @"375", @"155", @"564", @"275"];
   // self.graphView.labels = @[@"Hanahan Elemntary", @"Hanahan Middle School", @"Hanahan High School", @"Hanahan Pre-School", @"Hanahan Prep", @"Goose Creek Primary"];
    //int clicks[] = {100,250,375};
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupQueryForIndex:(NSUInteger)index
{
    switch ([self.queryType intValue])
    {
        case 1: //get corp stats
        case 2:
            self.idToQuery = [self.groupSelected objectForKey:ID];///get schools stats
            break;
        case 3: //get one schools stats
        case 4: //get one ads stats
            self.idToQuery = [[self.graphData objectAtIndex:index] objectForKey:ID];
            break;
    }
     [self getAdStatsFromDatabase];
}

- (void)setupQuery
{
    switch ([self.queryType intValue])
    {
        case 1: //get corp stats
        case 2:
            
            self.idToQuery = [self.groupSelected objectForKey:ID];///get schools stats
            break;
        case 3: //get one schools stats
            self.idToQuery = [self.schoolSelected objectForKey:SCHOOL_ID];
            break;
    }
    [self getAdStatsFromDatabase];
}

- (void)setupLineQuery
{
    self.previousIdToQuery = self.idToQuery;
    switch ([self.queryType intValue])
    {
        case 6:
        case 7:
            self.idToQuery = [[self.graphData objectAtIndex:self.index]objectForKey:ID];
            break;
    }
    [self getAdStatsFromDatabase];

}

- (IBAction)graphBackButtonPressed
{
  
       
    if(self.chartType == 2)
    {
         self.groupTextField.enabled = true;
        self.idToQuery = self.previousIdToQuery;
        self.chartType = 1;
        self.queryType = [NSString stringWithFormat:@"%i",[self.queryType intValue]  - 4];
        
        [self getAdStatsFromDatabase];
        
    }
    else
    {
        if([self.queryType intValue] > 1)
        {
            self.queryType = [NSString stringWithFormat:@"%i", [self.queryType intValue] - 1];
            if([self.queryType intValue] == 1)
                self.graphBackButton.hidden = true;
    
            [self setupQuery];
        }
    }
}

- (IBAction)graphReloadButtonPressed
{
    [self getAdStatsFromDatabase];
}

- (IBAction)emailGraphButtonPressed
{
    UIImage *image = [UIView captureView:self.view];
    
    NSData *data = UIImagePNGRepresentation(image);
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc]init];
    
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Ad Stats"];
    
    NSArray *toRecipients = [NSArray arrayWithObjects:@"rrumple@gmail.com", nil];
    [picker setToRecipients:toRecipients];
    
    [picker addAttachmentData:data mimeType:@"image/png" fileName:@"graph"];
    
    NSString *emailBody = @"Graph Data";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:picker animated:YES completion:nil];
    
    
    
}

- (void)barPressed:(NSDictionary *)data
{

    self.groupTextField.enabled = false;
    
    if([self.queryType intValue] < 4)
    {
        self.chartType = 2;
        self.queryType = [NSString stringWithFormat:@"%i", [self.queryType intValue] + 4];
        self.barType = [[data objectForKey:@"type"] intValue];
        self.index = [[data objectForKey:@"index"] intValue];
        [self setupLineQuery];
        
    }
    
    
    
    
    
}

- (void)buttonPressedOnGraph:(NSUInteger)index
{
    NSLog(@"%@", self.graphView.labels[index]);
    if([self.queryType intValue] < 4)
    {
        self.queryType = [NSString stringWithFormat:@"%i", [self.queryType intValue] + 1];

        [self setupQueryForIndex:index];
        self.graphBackButton.hidden = false;
    }
    if([self.queryType intValue] == 3)
    {
        self.schoolSelected = [[NSDictionary alloc]initWithObjectsAndKeys:[[self.graphData objectAtIndex:index] objectForKey:@"label"], @"label", [[self.graphData objectAtIndex:index]objectForKey:ID], SCHOOL_ID,nil];
    }
    
}

- (void)startCorpQuery
{
    self.queryType = @"1";
    self.idToQuery = [self.groupSelected objectForKey:ID];
    [self getAdStatsFromDatabase];
    self.emailGraphButton.hidden = false;
    self.graphReloadButton.hidden = false;}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark Delegate Section


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerGroup)
        return [self.groupPickerValues count];
    
    
    
    
    
    return 0;
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerGroup)
    {
        
         return [[self.groupPickerValues
                  objectAtIndex:row]objectForKey:@"name"];
        
    }
    
    return @"";
}




-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerGroup)
    {
        self.groupTextField.text =  [[self.groupPickerValues
                 objectAtIndex:row]objectForKey:@"name"];
        self.groupSelected = [self.groupPickerValues objectAtIndex:row];
        [self startCorpQuery];
       
    }
    
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}


-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    
    if(self.groupTextField.isFirstResponder)
    {
        if ([self.groupTextField.text isEqualToString:@""])
        {
           
            self.groupTextField.text =  [[self.groupPickerValues
                                          objectAtIndex:0]objectForKey:@"name"];
            self.groupSelected = [self.groupPickerValues objectAtIndex:0];
            [self startCorpQuery];
            
        }
        
        
    }
}

- (void)pickerViewTapped
{
    if(self.groupTextField.isFirstResponder)
    {
        
        [self hideKeyboard];
        
    }
       
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)hideKeyboard
{
    
    [self.groupTextField resignFirstResponder];
    
    
    
    
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;
    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    
    
    
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case groupTextbox1:
            if([textField.text length] > 0)
        {
            
            //[self.cityIndicatorView startAnimating];
                       //[self setupDatabaseQuery];
            
            
            
        }
            break;
    }
    
}





@end
