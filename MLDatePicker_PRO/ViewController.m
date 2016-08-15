//
//  ViewController.m
//  MLDatePicker_PRO
//
//  Created by Mrlu-bjhl on 16/8/15.
//  Copyright © 2016年 Mrlu. All rights reserved.
//

#import "ViewController.h"
#import "MLDateViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    MLDateViewController *vc = [MLDateViewController new];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
