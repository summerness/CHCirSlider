//
//  CHcir_Slider.h
//  cir_Slider
//
//  Created by summer_ness on 16/8/18.
//  Copyright © 2016年 summer_ness. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CHcirsliderDelegate <NSObject>
@optional
- (void)minIntValueChanged:(CGFloat)minIntValue;

- (void)maxIntValueChanged:(CGFloat)maxIntValue;

@end




@interface CHcir_Slider : UIControl


@property (nonatomic, assign)  CGFloat startAngle;

@property (nonatomic, assign)  CGFloat cutoutAngle;

@property (nonatomic, assign)  CGFloat progress;

@property (nonatomic, assign)  CGFloat progress1;

@property (nonatomic, assign)  CGFloat lineWidth;

@property (nonatomic, strong)  UIColor *guideLineColor;

@property (nonatomic, strong)  UIColor *guideLineColor1;

@property (nonatomic, strong)  UIColor *guidecoverColor;

@property (nonatomic, strong)  UIColor *guidecoverColor1;

@property (nonatomic, assign)  CGFloat handleOutSideRadius;

@property (nonatomic, assign)  CGFloat handleInSideRadius;

@property (weak, nonatomic)  id<CHcirsliderDelegate> delegate;
@end
