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

@interface NewsDetailViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *newsTextView;
@property (weak, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *attachmentButton;
@property (weak, nonatomic) IBOutlet UIWebView *newsWebView;

@property (weak, nonatomic) IBOutlet UIView *loadingIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingActivityViewLabel;


@end

@implementation NewsDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"News_Detail_Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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
