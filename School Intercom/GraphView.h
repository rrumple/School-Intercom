//
//  GraphView.h
//  graphTutorial
//
//  Created by Randall Rumple on 12/14/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@protocol GraphViewDelegate;


//#define kGraphHeight 330
//#define kDefaultGraphWidth 375
//#define kOffsetX 10
#define kStepX 50
//#define kGraphBottom 330
#define kGraphTop 0
#define kStepY 50
#define kOffsetY 10
#define kBarTop 10
#define kBarWidth 40
//#define kNumberOfBars 3
#define kSpaceBetweenBars 30
#define kBottomOffset 30
#define kCircleRadius 3

@interface GraphView : UIView

@property (nonatomic, weak) id<GraphViewDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *impressions;
@property (nonatomic) int chartType;
@property (nonatomic, strong) NSMutableArray *lineData;
@property (nonatomic, strong) NSMutableArray *clicks;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic) NSUInteger kNumberOfBars;
@property (nonatomic, strong) NSString *queryType;
@property (nonatomic, strong) NSString *titleAddOn;


-(void)setGraphData:(NSDictionary *)graphData;

@end

@protocol GraphViewDelegate <NSObject>

@required

- (void)buttonPressedOnGraph:(NSUInteger)index;
- (void)barPressed:(NSDictionary *)data;

@end
