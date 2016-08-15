//
//  Created by Mrlu-bjhl on 16/8/11.
//  Copyright © 2016年 Mrlu. All rights reserved.
//

#import "MLDatePicker.h"
#import "MLDatepickerCell.h"
#import "NSDate+MLDatePicker.h"

const NSUInteger kMaxPage = 3;
const CGFloat kDIDatepickerHeight = 60.;
const CGFloat kDIDatepickerSpaceBetweenItems = 15.;

NSString * const kDIDatepickerCellIndentifier = @"kDIDatepickerCellIndentifier";

@interface MLDatePicker (){
    NSIndexPath *selectedIndexPath;
}

@property (strong, nonatomic) UICollectionView *datesCollectionView;
@property (strong, nonatomic, readwrite) NSDate *selectedDate;

// methods
- (void)fillDatesFromDate:(NSDate *)fromDate numberOfDays:(NSInteger)nextDatesCount;
- (void)fillCurrentWeek;
- (void)fillCurrentMonth;
- (void)fillCurrentYear;

- (void)selectDateAtIndex:(NSUInteger)index;

@end


@implementation MLDatePicker

- (void)awakeFromNib
{
    [self setupViews];
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _selectedDate = [NSDate date];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor whiteColor];
    self.bottomLineColor = [UIColor colorWithWhite:0.816 alpha:1.000];
    self.selectedDateBottomLineColor = self.tintColor;
}

#pragma mark Setters | Getters

- (void)setDates:(NSArray *)dates
{
    _dates = dates;
    [self.datesCollectionView reloadData];
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    [self setSelectedDate:selectedDate scroll:NO];
}

- (void)setSelectedDate:(NSDate *)selectedDate scroll:(BOOL)scroll
{
    [self setSelectedDate:selectedDate scroll:scroll event:YES];
}

- (void)setSelectedDate:(NSDate *)selectedDate scroll:(BOOL)scroll event:(BOOL)enableEvent;
{
    if (selectedDate) {
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&selectedDate interval:NULL forDate:selectedDate];
    }
    _selectedDate = selectedDate;
    if (!selectedDate) {
        return;
    }
    NSIndexPath *selectedCellIndexPath = [NSIndexPath indexPathForItem:[self.dates indexOfObject:selectedDate] inSection:0];
    if (![selectedCellIndexPath isEqual:selectedIndexPath]) {
        [self.datesCollectionView deselectItemAtIndexPath:selectedIndexPath animated:YES];
        [self.datesCollectionView selectItemAtIndexPath:selectedCellIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        selectedIndexPath = selectedCellIndexPath;
        if (scroll) {
            NSUInteger page = [self getCurrentPage:selectedIndexPath];
            [self.datesCollectionView setContentOffset:CGPointMake(page*CGRectGetWidth(self.bounds), 0) animated:NO];
        }
        if (enableEvent) {
           [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

- (UICollectionView *)datesCollectionView
{
    if (!_datesCollectionView) {
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        [collectionViewLayout setItemSize:CGSizeMake(CGRectGetWidth(self.frame)/7, CGRectGetHeight(self.bounds))];
        [collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [collectionViewLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        [collectionViewLayout setMinimumLineSpacing:0];
        
        _datesCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:collectionViewLayout];
        _datesCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_datesCollectionView registerClass:[MLDatepickerCell class] forCellWithReuseIdentifier:kDIDatepickerCellIndentifier];
        [_datesCollectionView setBackgroundColor:[UIColor clearColor]];
        [_datesCollectionView setShowsHorizontalScrollIndicator:NO];
        [_datesCollectionView setAllowsMultipleSelection:YES];
        _datesCollectionView.dataSource = self;
        _datesCollectionView.delegate = self;
        _datesCollectionView.pagingEnabled = YES;
        _datesCollectionView.scrollsToTop = NO;
        _datesCollectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
        [self addSubview:_datesCollectionView];
    }
    return _datesCollectionView;
}

- (void)setSelectedDateBottomLineColor:(UIColor *)selectedDateBottomLineColor
{
    _selectedDateBottomLineColor = selectedDateBottomLineColor;
    
    [self.datesCollectionView.indexPathsForSelectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MLDatepickerCell *selectedCell = (MLDatepickerCell *)[self.datesCollectionView cellForItemAtIndexPath:obj];
        selectedCell.itemSelectionColor = _selectedDateBottomLineColor;
    }];
}

- (NSUInteger)getCurrentPage:(NSIndexPath *)indexPath
{
    NSUInteger page = (indexPath.row)/7+( (indexPath.row)%7>=0?1:0) - 1;
    return page;
}

- (NSUInteger)getCurrentPageWithOffsetX:(CGFloat)offsetX
{
    NSUInteger page = floorf(offsetX/CGRectGetWidth(self.bounds));
    return page;
}

#pragma mark Public methods

- (void)selectDate:(NSDate *)date
{
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&date interval:NULL forDate:date];
    
    NSAssert([self.dates indexOfObject:date] != NSNotFound, @"Date not found in dates array");
    [self setSelectedDate:date scroll:NO event:NO];
}

- (void)selectDateAtIndex:(NSUInteger)index
{
    NSAssert(index < self.dates.count, @"Index too big");
    [self setSelectedDate:self.dates[index] scroll:NO event:NO];
}

// -
- (void)fillDatesFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSAssert([fromDate compare:toDate] == NSOrderedAscending, @"toDate must be after fromDate");
    
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    NSDateComponents *days = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger dayCount = 0;
    while(YES){
        [days setDay:dayCount++];
        NSDate *date = [calendar dateByAddingComponents:days toDate:fromDate options:0];
        [calendar rangeOfUnit:NSDayCalendarUnit startDate:&date interval:NULL forDate:date];
        if([date compare:toDate] == NSOrderedDescending) break;
        [dates addObject:date];
    }
    
    self.dates = dates;
}

- (void)fillDatesFromDate:(NSDate *)fromDate numberOfDays:(NSInteger)numberOfDays
{
    NSDateComponents *days = [[NSDateComponents alloc] init];
    [days setDay:numberOfDays];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [self fillDatesFromDate:fromDate toDate:[calendar dateByAddingComponents:days toDate:fromDate options:0]];
}

- (void)fillCurrentWeek
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:today];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: - ((([weekdayComponents weekday] - [calendar firstWeekday]) + 7 ) % 7)];
    NSDate *beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setDay:6];
    NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:beginningOfWeek options:0];
    
    [self fillDatesFromDate:beginningOfWeek toDate:endOfWeek];
}

- (void)fillCurrentMonth
{
    [self fillDatesWithCalendarUnit:NSCalendarUnitMonth];
}

- (void)fillCurrentYear
{
    [self fillDatesWithCalendarUnit:NSCalendarUnitYear];
}

- (void)fillCurrentDateRangeWeek
{
    [self fillDateRangeWeek:[NSDate date]];
}

- (void)fillDateRangeWeek:(NSDate *)date
{
    // 循环kMaxPage周
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:date];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: - ((([weekdayComponents weekday] - [calendar firstWeekday]) + 7 ) % 7)];
    NSDate *beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:date options:0];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setDay:6];
    NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:beginningOfWeek options:0];
    
    [self fillDatesFromDate:[beginningOfWeek backDays:floor(kMaxPage/2)*7] toDate:[endOfWeek nextDays:floor(kMaxPage/2)*7]];
}

- (NSArray *)weekDates
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self.selectedDate];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: - ((([weekdayComponents weekday] - [calendar firstWeekday]) + 7 ) % 7)];
    NSDate *beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self.selectedDate options:0];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setDay:6];
    NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:beginningOfWeek options:0];
    
    NSAssert([beginningOfWeek compare:endOfWeek] == NSOrderedAscending, @"toDate must be after fromDate");
    
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    NSDateComponents *days = [[NSDateComponents alloc] init];
    
    NSInteger dayCount = 0;
    while(YES){
        [days setDay:dayCount++];
        NSDate *date = [calendar dateByAddingComponents:days toDate:beginningOfWeek options:0];
        [calendar rangeOfUnit:NSDayCalendarUnit startDate:&date interval:NULL forDate:date];
        if([date compare:endOfWeek] == NSOrderedDescending) break;
        [dates addObject:date];
    }
    return dates;
}


#pragma mark Private methods

- (void)fillDatesWithCalendarUnit:(NSCalendarUnit)unit
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *beginning;
    NSTimeInterval length;
    [calendar rangeOfUnit:unit startDate:&beginning interval:&length forDate:today];
    NSDate *end = [beginning dateByAddingTimeInterval:length-1];
    
    [self fillDatesFromDate:beginning toDate:end];
}

#pragma mark - UICollectionView Delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return  [self.dates count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MLDatepickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDIDatepickerCellIndentifier forIndexPath:indexPath];
    cell.date = [self.dates objectAtIndex:indexPath.item];
    cell.data = @{};
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return ![indexPath isEqual:selectedIndexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return ![indexPath isEqual:selectedIndexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedDate = [self.dates objectAtIndex:indexPath.item];
    if (![selectedIndexPath isEqual:indexPath]) {
        [collectionView deselectItemAtIndexPath:selectedIndexPath animated:YES];
        selectedIndexPath = indexPath;
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    scrollView.userInteractionEnabled = YES;
    NSUInteger pagex = [self getCurrentPageWithOffsetX:scrollView.contentOffset.x];
    NSUInteger page = [self getCurrentPage:selectedIndexPath];
    if (pagex == page) {
        return;
    }
    if (pagex>page) {
        self.selectedDate = [self.selectedDate nextDays:7];
    } else {
        self.selectedDate = [self.selectedDate backDays:7];
    }
    //页面循环
    if (pagex <= 0 || pagex >= kMaxPage-1) {
        [self fillDateRangeWeek:self.selectedDate];
        [self setSelectedDate:self.selectedDate scroll:YES];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    scrollView.userInteractionEnabled = NO; //防止快速滑动导致不调用对应 scrollViewDidEndDecelerating
}

@end
