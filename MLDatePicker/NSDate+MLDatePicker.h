//
//  Created by Mrlu-bjhl on 16/8/11.
//  Copyright © 2016年 Mrlu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (MLDatePicker)

+ (id)dateFormatter;
+ (id)dateFormatterWithFormat:(NSString *)dateFormat;

@end

@interface NSDate (MLDatePicker)

- (BOOL) isToday;

- (NSDate *)nextDays:(NSInteger)days;

- (NSDate *)backDays:(NSInteger)days;



@end
