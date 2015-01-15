//
//  GraphView.m
//  graphTutorial
//
//  Created by Randall Rumple on 12/14/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "GraphView.h"
#import "HelperMethods.h"

@interface GraphView ()

@property (nonatomic, strong) UILabel *barLabel;
@property (nonatomic, strong) NSMutableArray *chartData1;
@property (nonatomic, strong) NSMutableArray *chartData2;

@property (nonatomic) float kGraphHeight;
@property (nonatomic) float kDefaultGraphWidth;
@property (nonatomic) float kGraphBottom;
@property (nonatomic) float kOffsetX;
@property (nonatomic) int index;


@end

@implementation GraphView

- (NSMutableArray *)impressions
{
    if(!_impressions) _impressions = [[NSMutableArray alloc]init];
    return _impressions;
}

- (NSMutableArray *)clicks
{
    if(!_clicks) _clicks = [[NSMutableArray alloc]init];
    return _clicks;
}

- (NSMutableArray *)labels
{
    if(!_labels) _labels = [[NSMutableArray alloc]init];
    return _labels;
}


- (NSMutableArray *)chartData1
{
    if(!_chartData1) _chartData1 = [[NSMutableArray alloc]initWithCapacity:[self.impressions count]];
    return _chartData1;
}

- (NSMutableArray *)chartData2
{
    if(!_chartData2) _chartData2 = [[NSMutableArray alloc]initWithCapacity:[self.clicks count]];
    return _chartData2;
}
- (NSMutableArray *)lineData
{
    if(!_lineData) _lineData = [[NSMutableArray alloc]init];
    return _lineData;
}

//int impressions[] = {150, 375, 550};
//int clicks[] = {100,250,375};
//float data[] = {0.7, 0.4, 0.9};
//float data2[] = {0.3, 0.2, 0.7};
CGRect touchAreas[20];
CGRect touchAreas2[20];
CGRect touchAreas3[20];
CGRect touchAreas4[20];
CGRect touchAreas5[20];
CGRect barRect;


-(void)setGraphData:(NSDictionary *)graphData
{
    //NSArray *impressionsTemp = [graphData objectForKey:@"impressions"];
    //NSArray *clicksTemp = [graphData objectForKey:@"clicks"];
    
    
    
    
}
- (void)drawLineGraphWithContext:(CGContextRef)ctx
{
    float kLineGraphHeight = self.frame.size.height - kBottomOffset - kBarTop;
    //float data[] = {0.7, 0.4, 0.9, 1.0, 0.2, 0.85, 0.11, 0.75, 0.53, 0.44, 0.88, 0.77, 0.99, 0.55};
    //int count = (int)[self.lineData count];
    
    //float data[count];
    NSMutableArray *floatData = [[NSMutableArray alloc]init];
    
    //NSLog(@"%i", (int)sizeof(data)/4);
    
    float maxHeight = 0.0;
    
    for (int i = 0; i < [self.lineData count]; i++)
    {
        if ([self.lineData[i] floatValue] > maxHeight)
            maxHeight = [self.lineData[i] floatValue];
        
    }

   
    
    CGContextSetLineWidth(ctx, 2.0);
    CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:1.0 green:0.5 blue:0 alpha:1.0]CGColor]);
    maxHeight = maxHeight * 1.5;
    int maxGraphHeight = self.kGraphHeight - kOffsetY;
    for (int i = 0; i < [self.lineData count]; i++)
    {
        [floatData addObject:[NSString stringWithFormat:@"%f", [self.lineData[i] floatValue]  /(float)maxHeight]];
        //data[i]  = [self.lineData[i] floatValue]  /(float)maxGraphHeight;
        //self.chartData2[i] = [NSString stringWithFormat:@"%f", [self.clicks[i] floatValue] / maxGraphHeight];
    }

    
    CGGradientRef gradient;
    CGColorSpaceRef colorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = {0.0, 1.0};
    CGFloat components[8] = {1.0, 0.5, 0.0, 0.2, 1.0, 0.5, 0.0, 1.0};
    colorspace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    CGPoint startPoint, endPoint;
    startPoint.x = self.kOffsetX;
    startPoint.y = kLineGraphHeight;
    endPoint.x = self.kOffsetX;
    endPoint.y = kOffsetY;
    
    
    CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:1.0 green:0.5 blue:0 alpha:0.5]CGColor]);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, self.kOffsetX, kLineGraphHeight);
    /*
    CGContextAddLineToPoint(ctx, self.kOffsetX, kLineGraphHeight - maxGraphHeight * data[0]);
    for (int i = 1; i < sizeof(data)/4; i++)
    {
        CGContextAddLineToPoint(ctx, self.kOffsetX + i * kStepX, kLineGraphHeight - maxGraphHeight * data[i]);
    }
*/
    
    CGContextAddLineToPoint(ctx, self.kOffsetX, kLineGraphHeight - maxGraphHeight * [[floatData objectAtIndex:0]floatValue]);
    for (int i = 1; i < [floatData count]; i++)
    {
        CGContextAddLineToPoint(ctx, self.kOffsetX + i * kStepX, kLineGraphHeight - maxGraphHeight * [[floatData objectAtIndex:i]floatValue]);
    }
    CGContextAddLineToPoint(ctx, self.kOffsetX + ([floatData count]  - 1) * kStepX, kLineGraphHeight);
    CGContextClosePath(ctx);
    
    //CGContextDrawPath(ctx, kCGPathFill);
    
    CGContextSaveGState(ctx);
    CGContextClip(ctx);
    
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(ctx);
    CGColorSpaceRelease(colorspace);
    CGGradientRelease(gradient);
    
    
    CGContextBeginPath(ctx);
    /*
    CGContextMoveToPoint(ctx, self.kOffsetX, kLineGraphHeight - maxGraphHeight * data[0]);
    
    for (int i = 1; i < [self.lineData count]; i++)
    {
        //float data = [self.lineData[i] floatValue];
        CGContextAddLineToPoint(ctx, self.kOffsetX+ i * kStepX, kLineGraphHeight-maxGraphHeight * data[i]);
    }
    */
    
    CGContextMoveToPoint(ctx, self.kOffsetX, kLineGraphHeight - maxGraphHeight * [[floatData objectAtIndex:0]floatValue]);
    
    for (int i = 1; i < [self.lineData count]; i++)
    {
        //float data = [self.lineData[i] floatValue];
        CGContextAddLineToPoint(ctx, self.kOffsetX+ i * kStepX, kLineGraphHeight-maxGraphHeight * [floatData[i] floatValue]);
    }

    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:1.0 green:0.5 blue:0 alpha:1.0]CGColor]);
    
    for (int i = 0; i < [self.lineData count] ; i++)
    {
        //float data = [self.lineData[i] floatValue];
        float x = self.kOffsetX + i * kStepX;
        //float y = kLineGraphHeight - maxGraphHeight * data[i];
        float y = kLineGraphHeight - maxGraphHeight * [floatData[i] floatValue];
        
        CGRect rect = CGRectMake(x - kCircleRadius, y - kCircleRadius, 2 * kCircleRadius, 2 * kCircleRadius);
        CGContextAddEllipseInRect(ctx, rect);
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(x - 10, y -20, 20, 10)];
        
        label2.text = self.lineData[i];
        
        label2.font = [UIFont systemFontOfSize:11];
        label2.textAlignment = NSTextAlignmentCenter;

        [self addSubview:label2];
        
        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake((x - 20), self.kGraphBottom , 40, 10)];
        
        NSArray *newDate = [HelperMethods getDateArrayFromString:self.labels[i]];
        
        if(i == 0)
        {
            CGRect newFrame = label3.frame;
            newFrame.origin.x = x - 13;
            label3.frame = newFrame;
        }
            
                            
        label3.text = [NSString stringWithFormat:@"%@-%@", newDate[1], newDate[2]];
        
        label3.font = [UIFont systemFontOfSize:9];
        label3.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:label3];

        
    }
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    
    
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    for (int i = 0; i < 20; i++)
    {
        touchAreas[i] = CGRectMake(-1, -1, 0, 0);
        touchAreas2[i] = CGRectMake(-1, -1, 0, 0);
        touchAreas3[i] = CGRectMake(-1, -1, 0, 0);
        touchAreas4[i] = CGRectMake(-1, -1, 0, 0);
        touchAreas5[i] = CGRectMake(-1, -1, 0, 0);
    }
    
    self.kGraphHeight = self.frame.size.height;
    self.kDefaultGraphWidth = self.frame.size.width;
    self.kGraphBottom = self.frame.size.height - kBottomOffset;
    self.kOffsetX = 10;
    
    self.barLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20,20)];
    self.barLabel.hidden = true;
    barRect = self.barLabel.frame;
    self.barLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:self.barLabel];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //UIImage *image = [UIImage imageNamed:@"background.png"];
    //CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    //CGContextDrawImage(context, imageRect, image.CGImage);
    
    CGContextSetLineWidth(context, 0.6);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGFloat dash[] = {2.0, 2.0};
    CGContextSetLineDash(context, 0.0, dash, 2);
    
    int howMany = (self.kDefaultGraphWidth - self.kOffsetX) / kStepX;
    
    for (int i = 0; i <= howMany; i++)
    {
        CGContextMoveToPoint(context, self.kOffsetX + i * kStepX, kGraphTop);
        CGContextAddLineToPoint(context, self.kOffsetX + i * kStepX, self.kGraphBottom - self.kOffsetX);
        
    }
    
    int howManyHorizontal = (self.kGraphBottom - kGraphTop - kOffsetY) /kStepY;
    
    for (int i = 0; i <= howManyHorizontal; i++)
    {
        CGContextMoveToPoint(context, self.kOffsetX, self.kGraphBottom-kOffsetY - i * kStepY);
        CGContextAddLineToPoint(context, self.kDefaultGraphWidth, self.kGraphBottom - kOffsetY - i * kStepY);
    }
    
    
    CGContextStrokePath(context);
    
    CGContextSetLineDash(context, 0, NULL, 0); //removes dash
    
    
    
    if(self.chartType == 1)
    {
        float maxHeight = 0.0;
        
        for (int i = 0; i < self.kNumberOfBars; i++)
        {
            if ([self.clicks[i] floatValue] > maxHeight)
                maxHeight = [self.clicks[i] floatValue];
            if ([self.impressions[i] floatValue] > maxHeight)
                maxHeight = [self.impressions[i] floatValue];
        }
        
        maxHeight = maxHeight * 1.25;
        
        for (int i = 0; i < self.kNumberOfBars; i++)
        {
            self.chartData1[i]  = [NSString stringWithFormat:@"%f",[self.impressions[i] floatValue]  /maxHeight];
            self.chartData2[i] = [NSString stringWithFormat:@"%f", [self.clicks[i] floatValue] / maxHeight];
        }

        float maxBarHeight = self.kGraphHeight - kBarTop - kOffsetY;
        
        for (int i = 0; i < self.kNumberOfBars; i++)
        {
            
            //float barX = self.kOffsetX + kStepX + i * kStepX - kBarWidth / 2;
            
            float barX = (self.kOffsetX * 2) + (i *kSpaceBetweenBars) + (i * 75);
            float barY = kBarTop - kBottomOffset + maxBarHeight - maxBarHeight * [self.chartData1[i] floatValue];
            float barHeight = maxBarHeight * [self.chartData1[i] floatValue];
            
            CGRect barRect = CGRectMake(barX, barY, kBarWidth, barHeight);
            [self drawBar:barRect context:context];
            touchAreas[i] = barRect;
            barRect.origin.y = kGraphTop;
            barRect.size.height = maxBarHeight;
            touchAreas5[i] = barRect;

        }
        
        for (int i = 0; i < self.kNumberOfBars; i++)
        {
            
            //float barX = self.kOffsetX + kStepX + i * kStepX - kBarWidth / 2;
            float barX = kBarWidth + (self.kOffsetX * 2) + (i *kSpaceBetweenBars) + (i * 75);
            float barY = kBarTop - kBottomOffset + maxBarHeight - maxBarHeight * [self.chartData2[i] floatValue];
            float barHeight = maxBarHeight * [self.chartData2[i] floatValue];
            
            CGRect barRect = CGRectMake(barX, barY, kBarWidth, barHeight);
            
            
            [self drawClickBar:barRect context:context];
            
            touchAreas2[i] = barRect;
            barRect.origin.y = kGraphTop;
            barRect.size.height = maxBarHeight;
            touchAreas4[i] = barRect;
        }
        
        
        CGContextSetTextMatrix(context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
        
        
        CGContextSetTextDrawingMode(context, kCGTextFill);
        CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0] CGColor]);
        
        
        for (int i = 0; i < self.kNumberOfBars; i++)
        {
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(touchAreas[i].origin.x - 10, self.kGraphBottom + 2 , 100, 30)];
            
            NSString *newString = [self.labels[i] stringByReplacingOccurrencesOfString:@"Corporation" withString:@"Corp."];
            
            label.numberOfLines = 2;
            label.text = newString;
            label.font = [UIFont systemFontOfSize:11];
            label.textAlignment = NSTextAlignmentCenter;
            touchAreas3[i] = label.frame;
            
            [self addSubview:label];
            
            UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(touchAreas[i].origin.x - 5, touchAreas[i].origin.y + 5, 50, 10)];
            
            label2.text = self.impressions[i];
            
            
            label2.font = [UIFont systemFontOfSize:11];
            label2.textAlignment = NSTextAlignmentCenter;
            
            UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(touchAreas2[i].origin.x + 10, touchAreas2[i].origin.y + 5, 20, 10)];
            
            float difference = ([self.clicks[i] floatValue] / [self.impressions[i] floatValue] * 100.00);
            
            if(difference <= 10)
            {
                CGRect newFrame = CGRectMake(touchAreas2[i].origin.x + 10, self.kGraphBottom - 7, 20, 10);
                label3.frame = newFrame;
            }
            
            
            
            label3.text = self.clicks[i];
            label3.font = [UIFont systemFontOfSize:11];
            label3.textAlignment = NSTextAlignmentCenter;
            
            [self addSubview:label2];
            [self addSubview:label3];
            
            
        }
        
        float barX = kBarWidth + (self.kOffsetX * 2) + (self.kNumberOfBars *kSpaceBetweenBars) + (self.kNumberOfBars * 75);
        [self drawBar:CGRectMake(barX-25, self.kGraphHeight /2 - 20, 20, 20) context:context];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(barX, self.kGraphHeight / 2 - 20 , 100, 15)];
        
        
        label.text = @"- Impressions";
        label.font = [UIFont systemFontOfSize:11];
        label.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:label];
        
        [self drawClickBar:CGRectMake(barX-25, self.kGraphHeight/2 + 20, 20, 20) context:context];
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(barX, self.kGraphHeight / 2 + 20 , 100, 15)];
        
        
        label2.text = @"- Clicks";
        label2.font = [UIFont systemFontOfSize:11];
        label2.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:label2];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.superview.frame.size.width /2 - 250, kGraphTop + 3, 500, 10)];
        NSString *titleText;
        NSString *newString;
        switch ([self.queryType intValue])
        {
            case 1:  newString = [self.titleAddOn stringByReplacingOccurrencesOfString:@"Corporation" withString:@"Corp."];
                titleText = [NSString stringWithFormat:@"Impressions and Clicks for %@", newString];
                break;
            case 2: newString = [self.titleAddOn stringByReplacingOccurrencesOfString:@"Corporation" withString:@"Corp."];titleText = [NSString stringWithFormat:@"Impression and Clicks for each school in %@", newString];
                break;
            case 3: titleText = [NSString stringWithFormat:@"Impressions and Clicks for all ads at %@", self.titleAddOn];
                break;
            case 4: titleText = [NSString stringWithFormat:@"Impressions and Clicks for the %@ campaign", self.titleAddOn];
                break;
            default: titleText = @"Choose a Corporation from the Dropdown above";
                break;
        }
        
        titleLabel.text = titleText;
        titleLabel.font = [UIFont systemFontOfSize:11];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];

        
    }
    else if(self.chartType == 2)
    {
        NSString *chartType;
        if(self.index == 1)
            chartType = @"Impressions";
        else if (self.index == 2)
            chartType = @"Clicks";
        
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.superview.frame.size.width /2 - 250, kGraphTop + 3, 500, 10)];
        NSString *titleText;
        NSString *newString;
        switch ([self.queryType intValue])
        {
            case 5:  newString = [self.titleAddOn stringByReplacingOccurrencesOfString:@"Corporation" withString:@"Corp."];
                titleText = [NSString stringWithFormat:@"Daily %@ for all active ads in %@", chartType, newString];
                break;
            case 6:
                titleText = [NSString stringWithFormat:@"Daily %@ for all active ads for %@", chartType, self.titleAddOn];
                break;
            case 7: titleText = [NSString stringWithFormat:@"Daily %@ for the %@", chartType, self.titleAddOn];
                break;
            case 8: titleText = [NSString stringWithFormat:@"Daily %@ for the %@ campaign", chartType, self.titleAddOn];
                break;
            //default: titleText = @"Choose a Corporation from the Dropdown above";
                //break;
        }
        titleLabel.text = titleText;
        titleLabel.font = [UIFont systemFontOfSize:11];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];


        [self drawLineGraphWithContext:context];
    }
    
    
    
    
}


- (void)drawBar:(CGRect)rect context:(CGContextRef)ctx
{
    
    CGFloat components[12] = {0.2314, 0.5686, 0.4, 1.0,  // Start color
                              0.4727, 1.0, 0.8157, 1.0, // Second color
                              0.2392, 0.5686, 0.4118, 1.0};
    
    CGFloat locations[3] = {0.0, 0.33, 1.0};
    
    
    size_t num_locations = 3;

    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    CGPoint startPoint = rect.origin;
    CGPoint endPoint = CGPointMake(rect.origin.x +rect.size.width, rect.origin.y);
    
    
    CGContextBeginPath(ctx);
    
    CGContextSetGrayFillColor(ctx, 0.2, 0.7);
    
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
                         
    CGContextClosePath(ctx);
    
    CGContextSaveGState(ctx);
    CGContextClip(ctx);
    
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(ctx);
    
    CGColorSpaceRelease(colorspace);
    CGGradientRelease(gradient);
}

- (void)drawClickBar:(CGRect)rect context:(CGContextRef)ctx
{
    
    CGFloat components[12] = {0.4314, 0.2686, 0.4, 1.0,  // Start color
                              0.6727, 1.0, 0.9347, 1.0, // Second color
                              0.4392, 0.2686, 0.4118, 1.0};
    
    CGFloat locations[3] = {0.0, 0.33, 1.0};
    
    size_t num_locations = 3;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    CGPoint startPoint = rect.origin;
    CGPoint endPoint = CGPointMake(rect.origin.x +rect.size.width, rect.origin.y);
    
    
    CGContextBeginPath(ctx);
    
    CGContextSetGrayFillColor(ctx, 0.2, 0.7);
    
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    
    CGContextClosePath(ctx);
    
    CGContextSaveGState(ctx);
    CGContextClip(ctx);
    
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(ctx);
    
    CGColorSpaceRelease(colorspace);
    CGGradientRelease(gradient);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    NSLog(@"Touch x: %f, y:%f", point.x, point.y);
    
    for (int i = 0; i < self.kNumberOfBars; i++)
    {
        if (CGRectContainsPoint(barRect, point))
        {
            if(!self.barLabel.hidden)
            {
                self.barLabel.hidden = true;
                break;
            }
        }
        if (CGRectContainsPoint(touchAreas5[i], point))
        {
            //barRect.origin.x = touchAreas[i].origin.x + 10;
            //barRect.origin.y = touchAreas[i].origin.y + 5;
            //self.barLabel.frame = barRect;
            //self.barLabel.hidden = false;
            //self.barLabel.text = self.impressions[i];
            [self barPressed:i andType:1];
            NSLog(@"Tapped a bar with index %d, value %f", i, [self.chartData1[i] floatValue]);
            break;
        }
        if (CGRectContainsPoint(touchAreas4[i], point))
        {
            //barRect.origin.x = touchAreas2[i].origin.x + 10;
            //barRect.origin.y = touchAreas2[i].origin.y + 5;
           // self.barLabel.frame = barRect;
           // self.barLabel.hidden = false;
            //self.barLabel.text = self.clicks[i];
            [self barPressed:i andType:2];
            NSLog(@"Tapped a Click Bar with index %d, value %f", i,[self.chartData2[i] floatValue]);
                  break;
        }
        if (CGRectContainsPoint(touchAreas3[i], point))
        {
            NSLog(@"Tapped a Bar Label with index %d, value %@", i, self.labels[i]);
            [self buttonPressed:i];
            break;
            
        }
        
        
    }
}

- (void)buttonPressed:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(buttonPressedOnGraph:)])
    {
        [self.delegate buttonPressedOnGraph:index];
    }
}

- (void)barPressed:(NSUInteger)index andType:(int)type
{
    self.index = type;
    NSDictionary *tempDic = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",(int)index], @"index", [NSString stringWithFormat:@"%i", type], @"type", nil];
    if ([self.delegate respondsToSelector:@selector(barPressed:)])
    {
        [self.delegate barPressed:tempDic];
    }

}


@end
