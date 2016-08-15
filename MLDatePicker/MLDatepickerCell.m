//
//  Created by Mrlu-bjhl on 16/8/11.
//  Copyright © 2016年 Mrlu. All rights reserved.
//

#import "MLDatepickerCell.h"
#import "NSDate+MLDatePicker.h"
#import <CoreText/CoreText.h>

#define DateFont @"PingFang-SC-Regular"

@interface MLDatepickerCell ()

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIView *selectionView;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSString * dayFormattedString;
@property (nonatomic, strong) NSString * dayInWeekFormattedString;
@property (nonatomic, strong) NSMutableAttributedString * dateString;

@end


@implementation MLDatepickerCell

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (void)prepareForReuse
{
    [self setSelected:NO];
    self.selectionView.alpha = 0.0f;
    self.lineView.alpha = 0.0f;
    self.dateFormatter = nil;
    self.dayInWeekFormattedString = nil;
    self.dateString = nil;
}

#pragma mark - Setters

- (void)setDate:(NSDate *)date
{
    _date = date;
    
    [self.dateFormatter setDateFormat:@"dd"];
    self.dayFormattedString = [self.dateFormatter stringFromDate:date];
    
    if ([date isToday]) {
        self.dayInWeekFormattedString = @"今天";
    } else {
        [self.dateFormatter setDateFormat:@"EEE"];
        self.dayInWeekFormattedString = [self.dateFormatter stringFromDate:date];
    }
    
    self.dateString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", self.dayFormattedString, [self.dayInWeekFormattedString uppercaseString]]];
    
    [self dateLabelStyle:self.selected];
    
    self.dateLabel.attributedText = self.dateString;
}

- (void)setData:(id)data
{
    if (self.selected) {
        self.lineView.alpha = (self.selected)?0.0f:1.0f;
    } else {
        self.lineView.alpha = data ? 1.0 : 0.0;
    }
}

- (void)setItemSelectionColor:(UIColor *)itemSelectionColor
{
    self.selectionView.backgroundColor = itemSelectionColor;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (!self.selected) {
        self.selectionView.hidden = NO;
        if (highlighted) {
            self.selectionView.alpha = self.isSelected ? 1 : .5;
        } else {
            self.selectionView.alpha = self.isSelected ? 1 : 0;
        }
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.selectionView.alpha = (selected)?1.0f:0.0f;
    [self dateLabelStyle:selected];
    self.dateLabel.attributedText = self.dateString;
    self.lineView.alpha = (selected)?0.0f:1.0f;
}

- (void)dateLabelStyle:(BOOL)selected
{
    if (selected) {
        [self.dateString addAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:DateFont size:20],
                                         NSForegroundColorAttributeName: [UIColor whiteColor]
                                         } range:NSMakeRange(0, self.dayFormattedString.length)];
        
        [self.dateString addAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:DateFont size:10],
                                         NSForegroundColorAttributeName: [UIColor whiteColor]
                                         } range:NSMakeRange(self.dayFormattedString.length + 1, self.dayInWeekFormattedString.length)];
    } else {
        [self.dateString addAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:DateFont size:20],
                                         NSForegroundColorAttributeName: [UIColor colorWithRed:80./255. green:61./255 blue:61./255 alpha:1]
                                         } range:NSMakeRange(0, self.dayFormattedString.length)];
        
        [self.dateString addAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:DateFont size:10],
                                         NSForegroundColorAttributeName: [UIColor colorWithRed:157./255. green:157./255 blue:158./255 alpha:1]
                                         } range:NSMakeRange(self.dayFormattedString.length + 1, self.dayInWeekFormattedString.length)];
    }
}

#pragma mark - Getters

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _dateLabel.numberOfLines = 2;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UIView *)selectionView
{
    if (!_selectionView) {
        CGFloat width = floorf(CGRectGetWidth(self.frame)-6);
        _selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 , width, width)];
        _selectionView.alpha = 0.0f;
        _selectionView.backgroundColor = [UIColor orangeColor];
        _selectionView.layer.cornerRadius = width/2;
        _selectionView.center = CGPointMake(CGRectGetWidth(self.frame)/2,CGRectGetHeight(self.frame)/2);
        [self addSubview:_selectionView];
        [self sendSubviewToBack:_selectionView];
    }
    return _selectionView;
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 1)];
        _lineView.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2 + 23);
        _lineView.alpha = 0.0f;
        _lineView.backgroundColor = [UIColor orangeColor];
        [self addSubview:_lineView];
    }
    return _lineView;
}

- (NSDateFormatter *)dateFormatter
{
    if(!_dateFormatter){
        _dateFormatter = [NSDateFormatter dateFormatter];
    }
    return _dateFormatter;
}

#pragma mark - Helper Methods

@end
