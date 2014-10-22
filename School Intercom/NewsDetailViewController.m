//
//  NewsDetailViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 1/2/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "NewsDetailViewController.h"

@interface NewsDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextView *newsTextView;
@property (weak, nonatomic) IBOutlet UILabel *newsTitleLabel;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.newsTitleLabel.text = [self.newsDetailData objectForKey:NEWS_TITLE];
    NSString *text = [@"<br />" stringByAppendingString:[self.newsDetailData objectForKey:NEWS_TEXT]];

    
    NSError *err = nil;
    self.newsTextView.attributedText = [[NSAttributedString alloc]initWithData:[text dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:&err];
    if(err)
        NSLog(@"Unable to parse label text: %@", err);
    
    [self.newsTextView.layer setCornerRadius:15.0f];
    [self.newsTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.newsTextView.layer setBorderWidth:1.5f];
    [self.newsTextView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.newsTextView.layer setShadowOpacity:0.8];
    [self.newsTextView.layer setShadowRadius:3.0];
    [self.newsTextView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];

                                        
    //self.newsTextView.text = [self.newsDetailData objectForKey:NEWS_TEXT];
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
