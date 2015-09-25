//
//  NewsDetailViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 1/2/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "NewsDetailViewController.h"
//#import "Flurry.h"
#import <Google/Analytics.h>
#import "NewsModel.h"

@interface NewsDetailViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *newsTextView;
@property (weak, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *otherAttachmentButton;

@property (weak, nonatomic) IBOutlet UIButton *attachmentButton;
@property (weak, nonatomic) IBOutlet UIWebView *newsWebView;

@property (weak, nonatomic) IBOutlet UIView *loadingIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingActivityViewLabel;

@property (nonatomic, strong) NewsModel *newsData;


@end

@implementation NewsDetailViewController

-(NewsModel *)newsData
{
    if(!_newsData) _newsData = [[NewsModel alloc]init];
    return _newsData;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"News_Detail_Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPushAlert:) name:@"DisplayAlert" object:nil];
    
    
}

- (void)showPushAlert:(NSNotification *)notification
{
    NSDictionary *data = [notification userInfo];
    
    [HelperMethods CreateAndDisplayOverHeadAlertInView:self.view withMessage:[data objectForKey:@"message"] andSchoolID:[data objectForKey:SCHOOL_ID]];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.loadingIndicatorView.hidden = true;
    [self.loadingActivityIndicator stopAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.loadingIndicatorView.layer setCornerRadius:30.0f];
    [self.loadingIndicatorView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.loadingIndicatorView.layer setBorderWidth:1.5f];
    [self.loadingIndicatorView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.loadingIndicatorView.layer setShadowOpacity:0.8];
    [self.loadingIndicatorView.layer setShadowRadius:3.0];
    [self.loadingIndicatorView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    //[Flurry logEvent:@"News_Article_Read"];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"News"
                                                          action:@"News_Article_Read"
                                                           label:[self.newsDetailData objectForKey:NEWS_TITLE]
                                                           value:@1] build]];
    
	self.newsTitleLabel.text = [self.newsDetailData objectForKey:NEWS_TITLE];
    NSString *text = [@"<br />" stringByAppendingString:[self.newsDetailData objectForKey:NEWS_TEXT]];
    
    if([[self.newsDetailData objectForKey:@"attachmentName"] length] > 0)
    {
        self.attachmentButton.hidden = false;
        self.otherAttachmentButton.hidden = false;
        self.loadingIndicatorView.hidden = false;
        self.loadingActivityViewLabel.text = @"Loading...";
        [self.loadingActivityIndicator startAnimating];
        self.newsWebView.delegate = self;
        self.newsWebView.hidden = false;
        self.newsWebView.scalesPageToFit = YES;
        //NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@", NEWS_ATTACHMENT_URL, [self.newsDetailData objectForKey:@"attacmentName"]] ofType:nil];
        //NSURL *url = [NSURL fileURLWithPath:path];
        NSString *urlString = [NSString stringWithFormat:@"%@%@", NEWS_ATTACHMENT_URL, [self.newsDetailData objectForKey:@"attachmentName"]];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.newsWebView loadRequest:request];
        
        
        
        [self.newsWebView.layer setCornerRadius:13.0f];
        [self.newsWebView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.newsWebView.layer setBorderWidth:1.5f];
        [self.newsWebView.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.newsWebView.layer setShadowOpacity:0.8];
        [self.newsWebView.layer setShadowRadius:3.0];
        [self.newsWebView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    }
    else
    {
        self.newsTextView.hidden = false;
        NSError *err = nil;
        self.newsTextView.attributedText = [[NSAttributedString alloc]initWithData:[text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:&err];
        if(err)
            NSLog(@"Unable to parse label text: %@", err);
        
        [self.newsTextView.layer setCornerRadius:13.0f];
        [self.newsTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.newsTextView.layer setBorderWidth:1.5f];
        [self.newsTextView.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.newsTextView.layer setShadowOpacity:0.8];
        [self.newsTextView.layer setShadowRadius:3.0];
        [self.newsTextView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    }
    
    

                                        
    //self.newsTextView.text = [self.newsDetailData objectForKey:NEWS_TEXT];
}
- (IBAction)attachmentButtonPressed
{
    [self.attachmentButton setEnabled:false];
    [self.otherAttachmentButton setEnabled:false];
        dispatch_queue_t createQueue = dispatch_queue_create("emailAttachment", NULL);
        dispatch_async(createQueue, ^{
            NSArray *emailArray;
            emailArray = [self.newsData emailPDFtoUser:self.userID withNewsID:[self.newsDetailData objectForKey:ID]];
            if (emailArray)
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSLog(@"%@", [emailArray objectAtIndex:0]);
                    
                    
                    if(![[[emailArray objectAtIndex:0]objectForKey:@"error"] boolValue])
                    {
                        
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"News Attachment"
                                                                              action:@"Request_to_Email_PDF"
                                                                               label:@"Emailed_PDF"
                                                                               value:@1] build]];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Sent" message:@"The PDF has been emailed to you." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                        alert.delegate = self;
                        
                        [alert show];
                
                        
                        
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Failure" message:@"PDF Sending Failed! Try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                        
                        [alert show];
                        
                    }
                    
                    
                    
                });
                
            }
        });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
