//
//  DemoCalendarMonth.m
//  Created by Devin Ross on 10/31/09.
//
/*
 
 tapku || https://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "CalendarMonthViewController.h"

@interface CalendarMonthViewController ()
@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSArray *monthsUsed;
@property (nonatomic, strong) NSArray *yearsUsed;
@property (nonatomic) BOOL showDetailView;
@property (nonatomic, strong) NSDictionary *detailViewDic;
@end

#pragma mark - CalendarMonthViewController
@implementation CalendarMonthViewController

-(NSDictionary *)detailViewDic
{
    if(!_detailViewDic) _detailViewDic = [[NSDictionary alloc]init];
    return _detailViewDic;
}

-(NSArray *)monthsUsed
{
    if(!_monthsUsed) _monthsUsed = [[NSArray alloc]init];
    return _monthsUsed;
}

-(NSArray *)monthArray
{
    if(!_monthArray) _monthArray = [[NSArray alloc]initWithObjects:
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    nil];
    return _monthArray;
    
}


- (NSArray *)getDateArrayFromString:(NSString *)date
{
    NSArray *dateArray = [date componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"- :/"]];
    NSLog(@"NEW DATE ARRAY: %@", dateArray);
    return dateArray;
    
}

- (void) datesToMarkStartDate:(NSDate *)start endDate:(NSDate *)end
{
    self.dataArray = [[NSMutableArray alloc]init];
    BOOL isMatched = NO;
    
    NSDate *d = start;
    	while(YES){
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:d];
        
        
        for(NSDictionary *calDic in self.calendarData)
        {
            NSArray *dateArray = [self getDateArrayFromString:[calDic objectForKey:CAL_START_DATE]];
            if([dateArray[1]integerValue] == [components month] && [dateArray[2]integerValue ] == [components day])
            {
                isMatched = YES;
                break;
            }
            else
            {
                isMatched = NO;
               
            }
            
        }
		
        if(isMatched)
            [self.dataArray addObject:@YES];
        else
            [self.dataArray addObject:@NO];
			
		NSDateComponents *info = [d dateComponentsWithTimeZone:self.monthView.timeZone];
		info.day++;
		d = [NSDate dateWithDateComponents:info];
		if([d compare:end]==NSOrderedDescending) break;
            
            
    }
}
- (void)getSectionCount
{
    
    NSMutableArray *tempArray = [self.monthArray mutableCopy];
    NSMutableArray *monthsUsed = [[NSMutableArray alloc]init];
    NSMutableArray *yearsUsed = [[NSMutableArray alloc]init];
    
    NSLog(@"%@", tempArray);
    NSLog(@"%@", self.calendarData);
    if(self.calendarData != (id)[NSNull null])
    {
        for(NSDictionary *calDic in self.calendarData)
        {
            NSArray *dateArray = [self getDateArrayFromString:[calDic objectForKey:CAL_START_DATE]];
            
            
            switch ([[dateArray objectAtIndex:1]integerValue])
            {
                case JANUARY:
                {
                    NSInteger number = [[tempArray objectAtIndex:JANUARY-1] integerValue];
                    number++;
                    [tempArray replaceObjectAtIndex:JANUARY-1 withObject:[NSNumber numberWithLong:number]];
                    if(![monthsUsed containsObject:[NSNumber numberWithInt:JANUARY]])
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:JANUARY]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                    }
                    
                    break;
                }
                case FEBUARY:
                {
                    NSInteger number = [[tempArray objectAtIndex:FEBUARY-1] integerValue];
                    number++;
                    [tempArray replaceObjectAtIndex:FEBUARY-1 withObject:[NSNumber numberWithLong:number]];
                    if(![monthsUsed containsObject:[NSNumber numberWithInt:FEBUARY]])
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:FEBUARY]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                    }
                    
                    break;
                }
                case MARCH:
                {
                    NSInteger number = [[tempArray objectAtIndex:2] integerValue];
                    number++;
                    [tempArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:number]];
                    if(![monthsUsed containsObject:[NSNumber numberWithInt:MARCH]])
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:MARCH]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                    }
                    
                    break;
                }
                case APRIL:
                {
                    NSInteger number = [[tempArray objectAtIndex:3] integerValue];
                    number++;
                    [tempArray replaceObjectAtIndex:3 withObject:[NSNumber numberWithLong:number]];
                    if(![monthsUsed containsObject:[NSNumber numberWithInt:APRIL]])
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:APRIL]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                    }
                    
                    break;
                }
                case MAY:
                {
                    NSInteger number = [[tempArray objectAtIndex:4] integerValue];
                    number++;
                    [tempArray replaceObjectAtIndex:4 withObject:[NSNumber numberWithLong:number]];
                    if(![monthsUsed containsObject:[NSNumber numberWithInt:MAY]])
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:MAY]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                    }
                    
                    break;
                }
                case JUNE:
                {
                    NSInteger number = [[tempArray objectAtIndex:5] integerValue];
                    number++;
                    [tempArray replaceObjectAtIndex:5 withObject:[NSNumber numberWithLong:number]];
                    if(![monthsUsed containsObject:[NSNumber numberWithInt:JUNE]])
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:JUNE]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                    }
                    
                    break;
                }
                case JULY:
                {
                    NSInteger number = [[tempArray objectAtIndex:6] integerValue];
                    number++;
                    [tempArray replaceObjectAtIndex:6 withObject:[NSNumber numberWithLong:number]];
                    if(![monthsUsed containsObject:[NSNumber numberWithInt:JULY]])
                    {
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [monthsUsed addObject:[NSNumber numberWithInt:JULY]];
                    }
                    break;
                }
                case AUGUST:
                {
                    NSInteger number = [[tempArray objectAtIndex:7] integerValue];
                    number++;
                    [tempArray replaceObjectAtIndex:7 withObject:[NSNumber numberWithLong:number]];
                    if(![monthsUsed containsObject:[NSNumber numberWithInt:AUGUST]])
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:AUGUST]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                    }
                    
                    break;
                }
                case SEPTEMBER:
                {
                    NSInteger number = [[tempArray objectAtIndex:SEPTEMBER -1] integerValue];
                    number++;
                    [tempArray replaceObjectAtIndex:SEPTEMBER -1 withObject:[NSNumber numberWithLong:number]];
                    if(![monthsUsed containsObject:[NSNumber numberWithInt:SEPTEMBER]])
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:SEPTEMBER]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                    }
                    break;
                }
                case OCTOBER:
                {
                    NSInteger number = [[tempArray objectAtIndex:9] integerValue];
                    number++;
                    [tempArray replaceObjectAtIndex:9 withObject:[NSNumber numberWithLong:number]];
                    if(![monthsUsed containsObject:[NSNumber numberWithInt:OCTOBER]])
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:OCTOBER]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                    }
                    
                    break;
                }
                case NOVEMBER:
                {
                    NSInteger number = [[tempArray objectAtIndex:10] integerValue];
                    number++;
                    [tempArray replaceObjectAtIndex:10 withObject:[NSNumber numberWithLong:number]];
                    if(![monthsUsed containsObject:[NSNumber numberWithInt:NOVEMBER]])
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:NOVEMBER]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                    }
                    break;
                }
                case DECEMBER:
                {
                    NSInteger number = [[tempArray objectAtIndex:11] integerValue];
                    number++;
                    [tempArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithLong:number]];
                    if(![monthsUsed containsObject:[NSNumber numberWithInt:DECEMBER]])
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:DECEMBER]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                    }
                    break;
                }
            }
        }
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Calendar Error" message:@"No Calendar Information to Display" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
    NSLog(@"YEARS USED%@", yearsUsed);
    
    
    self.monthArray = tempArray;
    self.monthsUsed = monthsUsed;
    self.yearsUsed = yearsUsed;
    
    
    
    
}

- (NSUInteger) supportedInterfaceOrientations{
	return  UIInterfaceOrientationMaskPortrait;
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


#pragma mark View Lifecycle
- (void) viewDidLoad{
	[super viewDidLoad];
    self.view.backgroundColor = self.backgroundColor;
    self.showDetailView = false;
    [self getSectionCount];
    NSLog(@"%@", self.calendarData);
	self.title = NSLocalizedString(@"Month Grid", @"");
	[self.monthView selectDate:[NSDate date]];
    CGRect rect = self.monthView.frame;
    rect.origin.y += 58;
    self.monthView.frame = rect;
    rect = self.tableView.frame;
    rect.origin.y += 58;
    self.tableView.frame = rect;
    
    UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
    
    [menuButton addTarget:self action:@selector(menuPressed) forControlEvents:UIControlEventTouchDown];
    
    [menuButton setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
    [self.view addSubview:menuButton];
    
    UIView *detailViewControls = [[UIView alloc]initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 40)];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 0, 40, 40)];
    UIButton *addButton = [[UIButton alloc]initWithFrame:CGRectMake(260, 0, 40, 40)];
    
    [backButton setTitle:@"⬅️" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:@"system" size:34.0];
    [backButton addTarget:self action:@selector(detailViewBackButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    [addButton setTitle:@"➕" forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont fontWithName:@"system" size:26.0];
    [addButton addTarget:self action:@selector(addEventToCalendar) forControlEvents:UIControlEventTouchDown];
    detailViewControls.backgroundColor = self.backgroundColor;
    [detailViewControls addSubview:backButton];
    [detailViewControls addSubview:addButton];
    
    [self.view insertSubview:detailViewControls belowSubview:self.tableView];

}

- (void)menuPressed
{
    if([self.delegate respondsToSelector:@selector(snapshotOfViewAsImage:)])
    {
        [self.delegate snapshotOfViewAsImage:[UIView captureView:self.view]];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)detailViewBackButtonPressed
{
    self.showDetailView = false;
    self.detailViewDic = nil;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y -= 40;
        self.tableView.frame = rect;
    }completion:^(BOOL finished) {
        //
    }];
    [self.tableView reloadData];
}

- (void)addEventToCalendar
{
    //NSString *dateString = @"Mon, 02 Sep 2013 00:00:45";
    NSLocale *usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    EKEventStore *store = [[EKEventStore alloc]init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)  {
        if (!granted)
            return;
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = [self.detailViewDic objectForKey:CAL_TITLE];
        event.allDay = [[self.detailViewDic objectForKey:CAL_IS_ALL_DAY] boolValue];
        event.startDate = [dateFormatter dateFromString:[self.detailViewDic objectForKey:CAL_START_DATE]];
        event.endDate = [dateFormatter dateFromString:[self.detailViewDic objectForKey:CAL_END_DATE]];
        event.location = [self.detailViewDic objectForKey:CAL_LOCATION];
        event.notes = [self.detailViewDic objectForKey:CAL_MORE_INFO];
        [event setCalendar:[store defaultCalendarForNewEvents]];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        
        NSLog(@"%@", event.eventIdentifier);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Calendar" message:@"Event added successfully" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            
            
        });
        
        
    }];
    

}


#pragma mark MonthView Delegate & DataSource
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate{
	[self datesToMarkStartDate:startDate endDate:lastDate];
    //[self generateRandomDataForStartDate:startDate endDate:lastDate];
	return self.dataArray;
}
- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date{
	NSLog(@"Date Selected: %@",date);
    
    if(self.showDetailView)
    {
        NSLocale *usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setLocale:usLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        for (NSDictionary *dic in self.calendarData)
        {
            NSDate *newDate = [dateFormatter dateFromString:[dic objectForKey:CAL_START_DATE]];
            
            if([newDate compare:date] == NSOrderedSame)
            {
                self.detailViewDic = dic;
                break;
            }
        }
    }
    
	[self.tableView reloadData];
}
- (void) calendarMonthView:(TKCalendarMonthView*)mv monthDidChange:(NSDate*)d animated:(BOOL)animated{
	[super calendarMonthView:mv monthDidChange:d animated:animated];
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.showDetailView)
        return 1;
    else
        return [self.monthsUsed count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int counter = 1;
    
    if (self.showDetailView)
    {
        if([[self.detailViewDic objectForKey:CAL_LOCATION] length] > 1)
            counter++;
        if([[self.detailViewDic objectForKey:CAL_MORE_INFO] length] > 1)
            counter++;
        
        return counter;
    }
    else
    {
        NSInteger num = [[self.monthsUsed objectAtIndex:section]integerValue];
    
        return [[self.monthArray objectAtIndex:num-1]integerValue];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.showDetailView && indexPath.row == 0)
    {
        return 105.0;
    }
    else if (self.showDetailView && indexPath.row == 1)
    {
        if([[self.detailViewDic objectForKey:CAL_LOCATION]length] > 1)
            return 44.0;
        else
            return 172.0;
    }
    else if (self.showDetailView && indexPath.row == 2)
        return 172.0;
    return 44.0f;
}

- (NSArray *)ConvertHourUsingDateArray:(NSArray *)dateArray
{
    NSMutableArray *newArray = [dateArray mutableCopy];
    NSInteger hour = [dateArray[3] integerValue];
    
    if(hour > 12)
    {
        hour -=12;
        if(hour == 12)
            newArray[5] = @"am";
        else
            newArray[5] = @"pm";
    }
    else
    {
        if(hour == 12)
            newArray[5] = @"pm";
        else
            newArray[5] = @"am";
    }
    
    newArray[3] = [NSString stringWithFormat:@"%li", (long)hour];
    
    return newArray;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(self.showDetailView)
    {
        if (indexPath.row == 0)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailViewTitleCell"];
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, 306, 21)];
            UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 49, 306, 41)];
            dateLabel.numberOfLines = 2;
            dateLabel.font = [UIFont systemFontOfSize:10.0];
            titleLabel.font = [UIFont systemFontOfSize:17.0];
            
            
            titleLabel.text = [self.detailViewDic objectForKey:CAL_TITLE];;
            NSArray *startTimeArray = [self getDateArrayFromString:[self.detailViewDic objectForKey:CAL_START_DATE]];
            NSArray *endTimeArray = [self getDateArrayFromString:[self.detailViewDic objectForKey:CAL_END_DATE]];
            
            
            
            
            if([[self.detailViewDic objectForKey:CAL_IS_ALL_DAY] boolValue])
            {
                if([endTimeArray[0] integerValue] > 0 && ![[self.detailViewDic objectForKey:CAL_START_DATE] isEqualToString:[self.detailViewDic objectForKey:CAL_END_DATE]])
                {
                    dateLabel.text = [NSString stringWithFormat:@"All day from %@ %@, %@ to %@ %@, %@", [self getMonthWithInt:[startTimeArray[1] integerValue]], startTimeArray[2], startTimeArray[0], [self getMonthWithInt:[endTimeArray[1] integerValue]], endTimeArray[2], endTimeArray[0]];
                }
                else
                {
                    dateLabel.text = [NSString stringWithFormat:@"All day on %@ %@, %@", [self getMonthWithInt:[startTimeArray[1] integerValue]], startTimeArray[2], startTimeArray[0]];
                }
            }
            else
            {
                startTimeArray = [self ConvertHourUsingDateArray:startTimeArray];
                endTimeArray = [self ConvertHourUsingDateArray:endTimeArray];
                
                dateLabel.text = [NSString stringWithFormat:@"On %@ %@, %@ from %@:%@%@ - %@:%@%@", [self getMonthWithInt:[startTimeArray[1] integerValue]], startTimeArray[2], startTimeArray[0], startTimeArray[3], startTimeArray[4], startTimeArray[5], endTimeArray[3], endTimeArray[4], endTimeArray[5]];
            }
            
            [cell addSubview:dateLabel];
            [cell addSubview:titleLabel];

        }
        else if (indexPath.row == 1 || indexPath.row == 2)
        {
            if([[self.detailViewDic objectForKey:CAL_LOCATION] length] > 1 && indexPath.row  == 1)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"locationCell"];
                cell.textLabel.text = @"Location";
                cell.detailTextLabel.text = [self.detailViewDic objectForKey:CAL_LOCATION];
                
            }
            else if ([[self.detailViewDic objectForKey:CAL_MORE_INFO] length] > 1)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moreInfoCell"];
                UILabel *moreInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 11, 143, 21)];
                UILabel *moreInfoTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 285, 111)];
                
                moreInfoLabel.font = [UIFont systemFontOfSize:17.0];
                moreInfoTextLabel.font = [UIFont systemFontOfSize:15.0];
                moreInfoTextLabel.numberOfLines = 5;
                
                moreInfoLabel.text = @"More Info";
                moreInfoTextLabel.text = [self.detailViewDic objectForKey:CAL_MORE_INFO];
                
                [cell addSubview:moreInfoLabel];
                [cell addSubview:moreInfoTextLabel];
            }
            
            
        }
    }
    else
    {
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        //UILabel *cellLabel = (UILabel *)[cell.contentView viewWithTag:2];
        //UILabel *calLabel = (UILabel *)[cell.contentView viewWithTag:1];
        
        NSInteger section = indexPath.section;
        NSInteger row = 0;
        
        if(section == 0)
            row = indexPath.row;
        else if(section > 0)
        {
            for (int i = 0; i < section; i++)
            {
                NSInteger num = [[self.monthsUsed objectAtIndex:i]integerValue];
                row += [[self.monthArray objectAtIndex:num-1]integerValue];
            }
            row += indexPath.row;
        }
        
        NSDictionary *calendarDic = [self.calendarData objectAtIndex:row];
        
        cell.textLabel.text = [calendarDic objectForKey:CAL_TITLE];
        
        NSArray *dateArray = [self getDateArrayFromString:[calendarDic objectForKey:CAL_START_DATE]];
        NSString *stringDate = [NSString stringWithFormat:@"%@/%@/%@", dateArray[1], dateArray[2], dateArray[0]];
        
        cell.detailTextLabel.text = stringDate;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSArray *dateArray = [self getDateArrayFromString:cell.detailTextLabel.text];
    NSString *newDate = [NSString stringWithFormat:@"%@-%@-%@ 00:00:00", dateArray[2], dateArray[0], dateArray[1]];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *myDate = [df dateFromString: newDate];
    NSLog(@"%@", myDate);
    [self.monthView selectDate:myDate];
    self.showDetailView = true;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y += 40;
        self.tableView.frame = rect;
    }completion:^(BOOL finished) {
        //
    }];
    
    for (NSDictionary *dic in self.calendarData)
    {
        NSArray *startTime = [self getDateArrayFromString:[dic objectForKey:CAL_START_DATE]];
        NSLog(@"%@",cell.textLabel.text);
        if([dateArray[2] isEqualToString:startTime[0]] && [dateArray[0] isEqualToString:startTime[1]] && [dateArray[1] isEqualToString:startTime[2]] && [cell.textLabel.text isEqualToString:[dic objectForKey:CAL_TITLE]])
        {
            self.detailViewDic = dic;
            NSLog(@"Match Found");
            break;
        }
    }
    [self.tableView reloadData];
    //[self performSegueWithIdentifier:@"calendarDetailSegue" sender:self];
    // Navigation logic may go here. Create and push another view controller.
    /*
      *detailViewController = [[  alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (NSString *)getMonthWithInt:(NSInteger)num
{
    NSString *month;
    
    switch(num)
    {
        case 1:
        {
            month = @"January";
            break;
        }
        case 2:
        {
            month = @"Febuary";
            break;
        }
        case 3:
        {
            month = @"March";
            break;
        }
        case 4:
        {
            month = @"April";
            break;
        }
        case 5:
        {
            month = @"May";
            break;
        }
        case 6:
        {
            month = @"June";
            break;
        }
        case 7:
        {
            month = @"July";
            break;
        }
        case 8:
        {
            month = @"August";
            break;
        }
        case 9:
        {
            month = @"September";
            break;
        }
        case 10:
        {
            month = @"October";
            break;
        }
        case 11:
        {
            month = @"November";
            break;
        }
        case 12:
        {
            month = @"December";
            break;
        }
    }
    
    return month;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if(self.showDetailView)
    {
    
        return nil;
    }
    else
    {
        NSString *headerText = [self getMonthWithInt:[[self.monthsUsed objectAtIndex:section] integerValue]];
    
        headerText = [headerText stringByAppendingString:@" - "];
    
        headerText = [headerText stringByAppendingString:[self.yearsUsed objectAtIndex:section]];
        
        return headerText;
    }
    
}
/*
#pragma mark UITableView Delegate & DataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
	NSArray *ar = self.dataDictionary[[self.monthView dateSelected]];
	if(ar == nil) return 0;
	return [ar count];
}
- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
	
    
	NSArray *ar = self.dataDictionary[[self.monthView dateSelected]];
	cell.textLabel.text = ar[indexPath.row];
	
    return cell;
	
}


- (void) generateRandomDataForStartDate:(NSDate*)start endDate:(NSDate*)end{
	// this function sets up dataArray & dataDictionary
	// dataArray: has boolean markers for each day to pass to the calendar view (via the delegate function)
	// dataDictionary: has items that are associated with date keys (for tableview)
	
	
	NSLog(@"Delegate Range: %@ %@ %@",start,end,@([start daysBetweenDate:end]));
	
	self.dataArray = [NSMutableArray array];
	self.dataDictionary = [NSMutableDictionary dictionary];
	
	NSDate *d = start;
	while(YES){
		
		NSInteger r = arc4random();
		if(r % 3==1){
			(self.dataDictionary)[d] = @[@"Item one",@"Item two"];
			[self.dataArray addObject:@YES];
			
		}else if(r%4==1){
			(self.dataDictionary)[d] = @[@"Item one"];
			[self.dataArray addObject:@YES];
			
		}else
			[self.dataArray addObject:@NO];
		
		
		NSDateComponents *info = [d dateComponentsWithTimeZone:self.monthView.timeZone];
		info.day++;
		d = [NSDate dateWithDateComponents:info];
		if([d compare:end]==NSOrderedDescending) break;
	}
	
}
*/

@end
