//
//  Created by Mrlu-bjhl on 16/8/11.
//  Copyright © 2016年 Mrlu. All rights reserved.
//

#import "MLDateHeaderView.h"
#import "NSDate+MLDatePicker.h"

@implementation MLDateHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setDate:(NSDate *)date
{
    self.textLabel.text = [[NSDateFormatter dateFormatterWithFormat:@"YYYY年MM月dd日 EEE"] stringFromDate:date];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundView.backgroundColor = [UIColor colorWithRed:242./255 green:244./255 blue:245./255 alpha:1];
    self.textLabel.textColor = [UIColor colorWithRed:109./255 green:109./255 blue:110./255 alpha:01];
    self.textLabel.font = [UIFont systemFontOfSize:14];
}

@end
