//
//  StateView.h
//  StateDemo
//
//  Created by 王晓东 on 15/12/15.
//  Copyright © 2015年 Ericdong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, displayState)  {
    displayStateNormal = 0,
    displayStateSuccess,
    displayStateFail
};
@interface StateView : UIView
@property  (strong, nonatomic) UIColor *circleColor;
@property (strong, nonatomic) UIColor *progressColor;
@property (strong, nonatomic) UIColor *successColor;
@property (strong, nonatomic) UIColor *failColor;
@property (assign, nonatomic) displayState state;
@property (copy, nonatomic) NSString *normalMsg;
@property (copy, nonatomic) NSString *successMsg;
@property (copy, nonatomic) NSString *failMsg;
@property (assign, nonatomic) CGFloat lineWidth;

@end


@interface AnimationView : UIView
@property (strong, nonatomic) CAShapeLayer *circleLayer;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (strong, nonatomic) CAShapeLayer *successLayer;
@property (strong, nonatomic) CAShapeLayer *failLayer;



@property (assign, nonatomic) CGFloat lineWidth;
@end
