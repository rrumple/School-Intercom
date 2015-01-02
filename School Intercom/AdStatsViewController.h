//
//  AdStatsViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 12/14/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "GraphView.h"
#import "UserData.h"


@interface AdStatsViewController : UIViewController <GraphViewDelegate>
@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UserData *mainUserData;
@end
