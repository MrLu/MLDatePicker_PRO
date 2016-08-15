//
//  Created by Mrlu-bjhl on 16/8/11.
//  Copyright © 2016年 Mrlu. All rights reserved.
//

#import "MLDateViewController.h"
#import "MLDatePicker.h"
#import "MLDateHeaderView.h"

@interface MLDateViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) MLDatePicker *datepicker;
@property (nonatomic, strong) UITableView *contentTableView;
@property (nonatomic, strong) NSArray *dates;
@end

@implementation MLDateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.datepicker = [[MLDatePicker alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), 64)];
    [self.datepicker addTarget:self action:@selector(updateWeekDates) forControlEvents:UIControlEventValueChanged];
    [self.datepicker addTarget:self action:@selector(updateSelectedDate) forControlEvents:UIControlEventTouchUpInside];
    [self.datepicker fillCurrentDateRangeWeek];
    
    [self.view addSubview:self.datepicker];
    
    [self.view addSubview:self.contentTableView];
    
    self.dates = self.datepicker.weekDates;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.datepicker setSelectedDate:[NSDate date] scroll:YES];
    [self updateSelectedDate];
}

- (void)updateSelectedDate
{
    //选中滚动tableView到当前位置
    NSInteger section = 0;
    for (int i = 0; i < self.dates.count; i++) {
        NSDate *date = self.dates[i];
        if ([date isEqualToDate:self.datepicker.selectedDate]) {
            section = i;
            break;
        }
    }
    [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)updateWeekDates
{
    //更新tableView
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEEddMMMM" options:0 locale:nil];
    self.dates = self.datepicker.weekDates;
}

- (void)updateDatepickerDate:(UITableView *)tableView
{
    if (tableView.tracking || tableView.decelerating) { //选中item自动滚动的时候不调用
        NSIndexPath *indexPath = [tableView indexPathsForVisibleRows].firstObject;
        [self.datepicker selectDate:self.dates[indexPath.section]];
    }
}

- (void)setDates:(NSArray *)dates
{
    _dates = dates;
    [self.contentTableView reloadData];
}

- (UITableView *)contentTableView
{
    if (!_contentTableView) {
        _contentTableView = [[UITableView alloc]initWithFrame:UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(CGRectGetMaxY(self.datepicker.frame), 0, 0, 0)) style:UITableViewStylePlain];
        [_contentTableView setDelegate:self];
        [_contentTableView setDataSource:self];
        [_contentTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_contentTableView setBackgroundView:nil];
        [_contentTableView setShowsVerticalScrollIndicator:NO];
        [_contentTableView setBackgroundColor:[UIColor whiteColor]];
        [_contentTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_contentTableView registerClass:[MLDateHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([MLDateHeaderView class])];
        UIView *headColorView = [[UIView alloc] initWithFrame:CGRectOffset(_contentTableView.bounds, 0, -_contentTableView.bounds.size.height)];
        headColorView.backgroundColor = [UIColor colorWithRed:242./255 green:244./255 blue:245./255 alpha:1];
        [_contentTableView addSubview:headColorView];
        [_contentTableView sendSubviewToBack:headColorView];
    }
    return _contentTableView;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MLDateHeaderView *v = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([MLDateHeaderView class])];
    [v setDate:(NSDate *)[self.dates objectAtIndex:section]];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 56;
    if (indexPath.section == 6 && indexPath.row == 1) {
        height = UIEdgeInsetsInsetRect(self.contentTableView.bounds,UIEdgeInsetsMake(0, 0, 30, 0)).size.height;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 30.;
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 1;
    if (section == 6) {
        num = 2;
    }
    return num;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger num = self.dates.count;
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        [cell setBackgroundView:[[UIView alloc] init]];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    [self updateDatepickerDate:tableView];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
    [self updateDatepickerDate:tableView];
}

@end
