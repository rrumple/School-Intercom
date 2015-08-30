//
//  AdminToolsQuickAddView.m
//  School Intercom
//
//  Created by Randall Rumple on 7/22/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "AdminToolsQuickAddView.h"

@implementation AdminToolsQuickAddView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"AdminToolsQuickAddView" owner:self options:nil];
        
        self.bounds = self.contentView.bounds;
        
        [self addSubview: self.contentView];
    }
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"AdminToolsQuickAddView" owner:self options:nil];
    
    // The following is to make sure content view, extends out all the way to fill whatever our view size is even as our view's size is changed by autolayout
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview: self.contentView];
    
    [[self class] addEdgeConstraint:NSLayoutAttributeLeft superview:self subview:self.contentView];
    [[self class] addEdgeConstraint:NSLayoutAttributeRight superview:self subview:self.contentView];
    [[self class] addEdgeConstraint:NSLayoutAttributeTop superview:self subview:self.contentView];
    [[self class] addEdgeConstraint:NSLayoutAttributeBottom superview:self subview:self.contentView];
    
}

+(void)addEdgeConstraint:(NSLayoutAttribute)edge superview:(UIView *)superview subview:(UIView *)subview {
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                          attribute:edge
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superview
                                                          attribute:edge
                                                         multiplier:1
                                                           constant:0]];
}

@end
