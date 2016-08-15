//
//  Created by Dmitry Ivanenko on 14.04.14.
//  Copyright (c) 2014 Dmitry Ivanenko. All rights reserved.
//

#import <UIKit/UIKit.h>


extern const CGFloat kDIDatepickerHeight;

@interface MLDatePicker : UIControl <UICollectionViewDataSource, UICollectionViewDelegate>

// data
@property (nonatomic, strong) NSArray *dates;
@property (nonatomic, strong, readonly) NSDate *selectedDate;
@property (nonatomic, strong, readonly) NSArray *weekDates;

// UI
@property (nonatomic, strong) UIColor *bottomLineColor;
@property (nonatomic, strong) UIColor *selectedDateBottomLineColor;


- (void)fillCurrentDateRangeWeek;

- (void)selectDate:(NSDate *)date;

- (void)setSelectedDate:(NSDate *)selectedDate scroll:(BOOL)scroll;


@end
