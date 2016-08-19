//
//  ViewController.m
//  cir_Slider
//
//  Created by summer_ness on 16/8/18.
//  Copyright © 2016年 summer_ness. All rights reserved.
//

#import "ViewController.h"
#import "CHcir_Slider.h"

@interface ViewController ()<CHcirsliderDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CHcir_Slider *cir = [[CHcir_Slider alloc]init];
    cir.startAngle = -90;
    cir.guideLineColor = [UIColor grayColor];
    cir.frame = CGRectMake(20, 100, 300, 300);
    cir.backgroundColor = [UIColor clearColor];
    [self.view addSubview:cir];
    cir.delegate = self;
}

- (void)minIntValueChanged:(CGFloat)minIntValue{
    NSLog(@"minIntValue%f",minIntValue);
}
- (void)maxIntValueChanged:(CGFloat)maxIntValue{
    NSLog(@"maxIntValue%f",maxIntValue);
}

@end
