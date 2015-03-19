//
//  ManagePostTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 2/1/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "ManagePostTableViewController.h"

@interface ManagePostTableViewController () <UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *addUpdateButton;
@property (weak, nonatomic) IBOutlet UITextField *postTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextfield;
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UIButton *InsertUpdateImageButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteImageButton;
@property (weak, nonatomic) IBOutlet UITextView *newsTextView;
@property (nonatomic, strong) NSString *dateUnaltered;
@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic, strong) NSString* newsImageFileName;
@property (weak, nonatomic) IBOutlet UISwitch *sendAlert;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UIButton *previewEditButton;
@property (nonatomic, strong) NSString *textViewDesignView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ManagePostTableViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)viewWillAppear:(BOOL)animated
{
    [Flurry logEvent:@"ADD_UPDATE_NEWS_POST_ACCESSED"];
    [super viewWillAppear:animated];
    
    if(self.isNewPost)
    {
        self.titleLabel.text = @"Add News Item";
        [self.addUpdateButton setTitle:@"Add" forState:UIControlStateNormal];
    }
}

- (void)updatePostInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("updatePost", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData updateNews:[self.postData objectForKey:ID] withNewsTitle:self.postTitleTextField.text andText:self.textViewDesignView andNewsImageName:self.newsImageFileName andNewsDate:self.dateUnaltered];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *success = [[UIAlertView alloc]initWithTitle:@"Update News Item" message:@"News Item was updated successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                success.tag = zAlertAddNewsSuccess;
                [success show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LOAD_DATA" object:nil userInfo:nil];
                
            });
            
        }
    });
    
}

- (void)addNewPostInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("addPost", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData addNewsForUser:self.mainUserData.userID withNewsTitle:self.postTitleTextField.text andText:self.textViewDesignView andNewsImageName:self.newsImageFileName andNewsDate:self.dateUnaltered sendAlert:[NSString stringWithFormat:@"%i", self.sendAlert.on]];
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *success = [[UIAlertView alloc]initWithTitle:@"Add News Item" message:@"News Item was added successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                success.tag = zAlertAddNewsSuccess;
                [success show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LOAD_DATA" object:nil userInfo:nil];
            });
            
        }
    });
    
}

- (NSString *)convertDate:(NSString *)date
{
    
    //NSLog(@"%@", date);
    NSArray *startTimeArray = [HelperMethods getDateArrayFromString:date];
    startTimeArray = [HelperMethods ConvertHourUsingDateArray:startTimeArray];
    
    
    return [NSString stringWithFormat:@"%@ %@, %@", [HelperMethods getMonthWithInt:[startTimeArray[1] integerValue]shortName:YES], startTimeArray[2], startTimeArray[0]];
    
}

- (NSString *)formatDate:(NSDate *)date
{
    
    return [self.dateFormatter stringFromDate:date];
}

- (void)startDatePickerValueChanged
{
    
    self.dateUnaltered = [self.dateFormatter stringFromDate:self.datePicker.date];
    self.dateTextfield.text = [self convertDate:[self formatDate:self.datePicker.date]];
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;
    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    
    
    
    
}


- (void)hideKeyboard
{
    [self.dateTextfield resignFirstResponder];
    [self.postTitleTextField resignFirstResponder];
    [self.newsTextView resignFirstResponder];

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.newsImageFileName = @"NULL";
    
    
    self.calendar = [NSCalendar currentCalendar];
    NSLocale *usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setLocale:usLocale];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    [self setupTapGestures];
    
    NSLocale *locale = [NSLocale currentLocale];

    self.datePicker = [[UIDatePicker  alloc]init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.locale = locale;
    self.datePicker.timeZone = [NSTimeZone localTimeZone];
    
    [self.datePicker addTarget:self action:@selector(startDatePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(hideKeyboard)];
    
    toolBar.barTintColor = [UIColor colorWithRed:0.820f green:0.835f blue:0.859f alpha:1.00f];
    
    toolBar.items = [[NSArray alloc] initWithObjects:barButtonDone,nil];
    barButtonDone.tintColor=[UIColor whiteColor];
    
    
    UIView *pickerParentView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, 320, 216)];
    [pickerParentView addSubview:self.datePicker];
    [pickerParentView addSubview:toolBar];
    self.dateTextfield.inputView = pickerParentView;

    
    
    self.postTitleTextField.text = [self.postData objectForKey:NEWS_TITLE];
    if(!self.isNewPost)
    {
        NSString *imageName = [self.postData objectForKey:NEWS_IMAGE_NAME];
        if(imageName != (id)[NSNull null])
        {
            self.spinner.hidden = false;
            [self loadNewsImageAtIndex:nil forImage:self.postImage withActivityIndicator:self.spinner];
        }
        else
            [self.spinner stopAnimating];

        self.dateTextfield.text = [self convertDate:[self.postData objectForKey:NEWS_DATE]];
        self.dateUnaltered = [self.postData objectForKey:NEWS_DATE];
        self.sendAlert.enabled = false;
        self.newsTextView.text = [self.postData objectForKey:NEWS_TEXT];
    }
    else
    {
        [self.spinner stopAnimating];
        self.dateUnaltered = [self.dateFormatter stringFromDate:[NSDate date]];
        self.dateTextfield.text = [self convertDate:[self formatDate:[NSDate date]]];
    }
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addUpdateButtonPressed:(UIButton *)sender
{
    if([[HelperMethods prepStringForValidation:self.postTitleTextField.text] length] > 0 && self.dateUnaltered && [[HelperMethods prepStringForValidation:self.newsTextView.text] length] > 0)
    {
        
        if(self.postImage.image)
           [self uploadImage];
        
        if([self.textViewDesignView length] < 1)
        {
            self.textViewDesignView = self.newsTextView.text;
        }
        
        if([sender.titleLabel.text isEqualToString:@"Add"])
        {
            [self addNewPostInDatabase];
        }
        else if([sender.titleLabel.text isEqualToString:@"Update"])
        {
            [self updatePostInDatabase];
        }

    }
    else
    {
        UIAlertView *moreInfo = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"News Items must have a title, a valid date, and News Text." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [moreInfo show];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}

- (IBAction)previewButtonPressed:(UIButton *)sender
{
    if([sender.titleLabel.text isEqualToString:@"Preview"])
    {
        [sender setTitle:@"Design" forState:UIControlStateNormal];
        
        self.textViewDesignView = self.newsTextView.text;
        
        NSString *text = [@"<br />" stringByAppendingString:self.newsTextView.text];
        
        
        NSError *err = nil;
        self.newsTextView.attributedText = [[NSAttributedString alloc]initWithData:[text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:&err];
        if(err)
            NSLog(@"Unable to parse label text: %@", err);
        
    }
    else if([sender.titleLabel.text isEqualToString:@"Design"])
    {
        [sender setTitle:@"Preview" forState:UIControlStateNormal];
        self.newsTextView.font = [UIFont systemFontOfSize:14.0];
        self.newsTextView.attributedText = nil;
        self.newsTextView.text = self.textViewDesignView;
    }
}

- (IBAction)addImageButtonPressed:(UIButton *)sender
{
    [self selectPhoto];
}

- (IBAction)deleteImageButtonPressed
{
    self.postImage.image = nil;
    self.newsImageFileName = @"NULL";
    self.deleteImageButton.enabled = false;
    [self.InsertUpdateImageButton setTitle:@"Insert Image" forState:UIControlStateNormal];
}

- (void)selectPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    self.postImage.image = selectedImage;
    self.deleteImageButton.enabled = true;
    [self.InsertUpdateImageButton setTitle:@"Update Image" forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)uploadImage
{
    
    double compressionRatio =1;
    NSData *imageData = UIImageJPEGRepresentation(self.postImage.image, compressionRatio);

    
    long long randomID = arc4random() % 9000000000000000 + 1000000000000000;
    
    NSString *fileName = [NSString stringWithFormat:@"%lld@2x.jpg",randomID ];
    self.newsImageFileName = fileName;
    
    //NSString *urlString = @"http://randy-2.local/test/uploadimage.php"
    NSString *urlString = [BASE_URL stringByAppendingString:@"upload_image.php"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=%@\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",returnString);
    
}

- (void)loadNewsImageAtIndex:(NSIndexPath *)path forImage:(UIImageView *)imageView withActivityIndicator:(UIActivityIndicatorView *)spinner
{
    
    NSString *fileName = [self.postData objectForKey:NEWS_IMAGE_NAME];
    
    NSString *baseImageURL = [NEWS_IMAGE_URL stringByAppendingString:fileName];
    
    NSLog(@"%@", baseImageURL);
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("get Image", NULL);
    dispatch_async(downloadQueue, ^{
        
        
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:baseImageURL]];
        dispatch_async(dispatch_get_main_queue(),^{
            UIImage *image = [UIImage imageWithData:data];
            
            // Get your image somehow
            
            
            // Begin a new image that will be the new image with the rounded corners
            // (here with the size of an UIImageView)
            UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, [UIScreen mainScreen].scale);
            
            // Add a clip before drawing anything, in the shape of an rounded rect
            [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                        cornerRadius:10.0] addClip];
            // Draw your image
            [image drawInRect:imageView.bounds];
            
            // Get the image, here setting the UIImageView image
            imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            
            // Lets forget about that we were drawing
            UIGraphicsEndImageContext();
            
            
            
            
            self.deleteImageButton.enabled = true;
            [self.InsertUpdateImageButton setTitle:@"Update Image" forState:UIControlStateNormal];
            [spinner stopAnimating];
            NSLog(@"%f, %f", image.size.width, image.size.height);
        });
        
        
    });
    
}


#pragma mark - Table view data source


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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertAddNewsSuccess)
        [self.navigationController popViewControllerAnimated:YES];
}

@end