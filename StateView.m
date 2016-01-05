//
//  StateView.m
//  StateDemo
//
//  Created by 王晓东 on 15/12/15.
//  Copyright © 2015年 Ericdong. All rights reserved.
//

#import "StateView.h"
NSString *const drawCircle = @"drawCircle";
NSString *const endCircle  = @"endCircle";
NSString *const rightAni = @"rightAni";
NSString *const wrongAni = @"wrongAni";
#define _startDegree @(0)
#define _endDegreee @(.9)
#define _duration 1.0
@interface StateView ()
@property (strong, nonatomic) AnimationView *stateView;
@property (copy, nonatomic) NSString *maxString;
@property (assign, nonatomic) CGSize orignalSize;

@property (strong, nonatomic) UILabel *msgLabel;
@property (assign, nonatomic) BOOL recycle;
@property (copy, nonatomic) void(^completeBlock)();
@end
@implementation StateView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _normalMsg  = @"加载中...";
        _successMsg = @"加载完成";
        _failMsg    = @"加载失败";
        _maxString  = self.failMsg;
        CGFloat radius = (frame.size.width > frame.size.height) ? frame.size.height : frame.size.width;
        [self createCircleWithRadius:radius];
        [self createMessageLabelWithRadius:radius];
        //init properties
        self.progressColor = [UIColor blueColor];
        self.successColor  = [UIColor redColor];
        self.failColor     = [UIColor yellowColor];
    }
    return self;
}
- (void)createCircleWithRadius:(CGFloat)radius {
    self.stateView = [[AnimationView alloc] initWithFrame:CGRectMake(0, 0, radius, radius)];
    CGRect frame = self.frame;
    self.stateView.center = CGPointMake(self.center.x - frame.origin.x, self.center.y - frame.origin.y);
    [self addSubview:_stateView];
}
- (void)createMessageLabelWithRadius:(CGFloat)radius {
    _orignalSize = CGSizeMake(self.frame.size.width, 20);
    self.msgLabel = [[UILabel alloc] init];
    _msgLabel.textAlignment = NSTextAlignmentCenter;
    [self fontSizeWithSize:_orignalSize title:self.maxString];
    [self addSubview:_msgLabel];
}
#pragma mark override setter and getter
- (void)setProgressColor:(UIColor *)progressColor {
    _stateView.progressLayer.strokeColor = progressColor.CGColor;
    _progressColor = progressColor;
}
- (void)setSuccessColor:(UIColor *)successColor {
    _stateView.successLayer.strokeColor = successColor.CGColor;
    _successColor = successColor;
}
- (void)setFailColor:(UIColor *)failColor {
    _stateView.failLayer.strokeColor = failColor.CGColor;
    _failColor = failColor;
}
- (void)setCircleColor:(UIColor *)circleColor {
    _stateView.circleLayer.strokeColor = circleColor.CGColor;
    _circleColor = circleColor;
}

- (void)setState:(displayState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    switch (state) {
        case 0:
        {
            [self startLoading];
            self.msgLabel.text = self.normalMsg;
            break;
        }
        case 1:
        {
            [self loadSuccess];
            __weak typeof (self) weakself = self;
            self.completeBlock = ^() {
                weakself.msgLabel.text = weakself.successMsg;
            };
            break;
        }
        case 2:
        {
            [self loadFail];
            __weak typeof (self) weakSelf = self;
            self.completeBlock = ^() {
                weakSelf.msgLabel.text = weakSelf.failMsg;
            };
            break;
        }
        default:
            break;
    }
}
- (void)setLineWidth:(CGFloat)lineWidth {
    _stateView.lineWidth = lineWidth;
}
-(void)setNormalMsg:(NSString *)normalMsg {
    _normalMsg = normalMsg;
    if (_maxString.length < normalMsg.length) {
        self.maxString = normalMsg;
    }
}
- (void)setSuccessMsg:(NSString *)successMsg {
    _successMsg = successMsg;
    if (_maxString.length < successMsg.length) {
        self.maxString = successMsg;
    }
}
- (void)setFailMsg:(NSString *)failMsg {
    _failMsg = failMsg;
    if (_maxString.length < failMsg.length) {
        self.maxString = failMsg;
    }
}
- (void)setMaxString:(NSString *)maxString {
    _maxString = maxString;
    [self fontSizeWithSize:_orignalSize title:self.maxString];
}
#pragma mark private methods

/**
 *  根据外部尺寸，是这label的最合适尺寸
 *
 *  @param size  预设的labelsize
 *  @param title 最长的文字描述
 *
 *  @return 最适合的文字字体号
 */
- (void)fontSizeWithSize:(CGSize)size title:(NSString *) title {
    NSLog(@"size = %@, title = %@", NSStringFromCGSize(size), title);
    
    CGFloat fonSize = 14;
    NSInteger bigger = 0;
    BOOL isRecycle = YES;
    while (isRecycle) {
        CGSize expectedSize = [title sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fonSize]}];
        if (expectedSize.width > size.width) {
            if (bigger == 1) {
                fonSize--;
            } else if (bigger == -1) {
                isRecycle = NO;
            } else {
                fonSize--;
            }
            bigger = 1;
        } else {
            if (bigger == 1) {
                isRecycle = NO;
            } else if (bigger == -1) {
                fonSize++;
            } else if (bigger == 0) {
                fonSize++;
            }
            bigger = -1;
        }
        if (!isRecycle) {
            CGRect frame = self.frame;
            frame.size.height = _stateView.frame.size.width + 5 + expectedSize.height;
            self.frame = frame;
            _msgLabel.font = [UIFont systemFontOfSize:fonSize];
            _msgLabel.bounds = CGRectMake(0, 0,expectedSize.width , expectedSize.height);
            _msgLabel.center = CGPointMake(_stateView.center.x, CGRectGetMaxY(_stateView.frame) + expectedSize.height / 2.0 + 5);
        }
    }
    
//    return fonSize;
}
- (void)startLoading {
    [_stateView.successLayer removeAllAnimations];
    _stateView.successLayer.path = nil;
    [_stateView.failLayer removeAllAnimations];
    _stateView.failLayer.path = nil;
    self.recycle = YES;
    [self drawCircleWithStartAngel:_startDegree endAngel:_endDegreee duration:_duration color:self.progressColor];
    CABasicAnimation *moveAni = ({
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        ani.repeatCount = NSIntegerMax;
        ani.byValue = @( M_PI * 2);
        ani.duration = 1.2;
        ani;
    });
    [_stateView.progressLayer addAnimation:moveAni forKey:@"moveAni"];
}
- (void)loadSuccess {
    self.recycle = NO;
    [self drawSuccess];
}
- (void)loadFail {
    self.recycle = NO;
    [self drawFail];
}
- (void)drawCircleWithStartAngel:(NSNumber *)start endAngel:(NSNumber *)end duration:(CGFloat)duration color:(UIColor*)color {
    UIBezierPath *bezierpath = [UIBezierPath bezierPath];
    CGRect frame = _stateView.bounds;
    [bezierpath addArcWithCenter:CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0) radius:frame.size.width / 2.0 startAngle:- M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
    self.stateView.progressLayer.strokeColor = color.CGColor;
    self.stateView.progressLayer.path = bezierpath.CGPath;
    CABasicAnimation *animation = ({
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [ani setValue:drawCircle forKey:@"id"];
        ani.delegate = self;
        ani.fromValue = start;
        ani.toValue   = end;
        ani.duration  = duration;
        ani;
    });
    [_stateView.progressLayer addAnimation:animation forKey:@"animation"];
    
}
- (void)closeCircle {
        CABasicAnimation *closeAni = ({
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [ani setValue:endCircle forKey:@"id"];
        ani.fromValue = _startDegree;
        ani.toValue   = _endDegreee;
        ani.delegate  = self;
        ani.duration = _duration;
        ani;
    });
    [_stateView.progressLayer addAnimation:closeAni forKey:@"closeAni"];
}
- (void)drawSuccess {
    [_stateView.failLayer removeAllAnimations];
    _stateView.failLayer.path = nil;
    
    UIBezierPath *rightPath = [UIBezierPath bezierPath];
    CGRect frame = _stateView.frame;
    CGFloat size = frame.size.width;
    [rightPath moveToPoint:CGPointMake(size/3.1578, size/2)];
    [rightPath addLineToPoint:CGPointMake(size/2.0618, size/1.57894)];
    [rightPath addLineToPoint:CGPointMake(size/1.3953, size/2.7272)];
    _stateView.successLayer.path = rightPath.CGPath;
    
    CABasicAnimation *successAni = ({
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [ani setValue:rightAni forKey:@"id"];
        ani.delegate = self;
        ani.fromValue = @(0);
        ani.toValue = @(1);
        ani.duration = 1.0;
        ani;
    });
    [_stateView.successLayer addAnimation:successAni forKey:@"successAni"];
    [_stateView.progressLayer removeAllAnimations];
    [self drawCircleWithStartAngel:_startDegree endAngel:_endDegreee duration:1.0 color:self.successColor];
    
}
- (void)drawFail {
    [_stateView.successLayer removeAllAnimations];
    _stateView.successLayer.path = nil;
    
    UIBezierPath *wrongPath = [UIBezierPath bezierPath];
    CGFloat size = _stateView.frame.size.width;
    [wrongPath moveToPoint:CGPointMake(size/3.5, size/3.5)];
    [wrongPath addLineToPoint:CGPointMake(size - size/3.5, size - size/3.5)];
    
    [wrongPath moveToPoint:CGPointMake(size - size/3.5, size/3.5)];
    [wrongPath addLineToPoint:CGPointMake(size/3.5, size - size/3.5)];
    _stateView.failLayer.path = wrongPath.CGPath;
    
    
    CABasicAnimation *failAni = ({
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [ani setValue:wrongAni forKey:@"id"];
        ani.delegate  = self;
        ani.fromValue = @(0);
        ani.toValue   = @(1.0);
        ani.duration  = 1.0;
        ani;
    });
    [_stateView.failLayer addAnimation:failAni forKey:@"failAni"];
    [_stateView.progressLayer removeAllAnimations];
    
    [self drawCircleWithStartAngel:_startDegree endAngel:_endDegreee duration:_duration color:self.failColor];
    
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSString *key = [anim valueForKey:@"id"];
    if ([key isEqualToString:drawCircle] && self.recycle) {
        [self closeCircle];
    } else if ([key isEqualToString:endCircle] && self.recycle) {
        [self drawCircleWithStartAngel:_startDegree endAngel:_endDegreee duration:_duration color:_progressColor];
    } else if ([key isEqualToString:rightAni] || [key isEqualToString:wrongAni]) {
        if (self.completeBlock) {
            self.completeBlock();
        }
    }
}

@end


@implementation AnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth = 4;
        [self.layer addSublayer:self.circleLayer];
        [self.layer addSublayer:self.progressLayer];
        [self.layer addSublayer:self.successLayer];
        [self.layer addSublayer:self.failLayer];
    }
    return self;
}

- (CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        self.circleLayer = [self createLayerWithColor:[UIColor lightGrayColor]];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.center radius:(self.bounds.size.width / 2.0) startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        self.circleLayer.path = path.CGPath;
        
    }
    return _circleLayer;
}
- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        self.progressLayer = [self createLayerWithColor:[UIColor blueColor]];
    }
    return _progressLayer;
}
- (CAShapeLayer *)successLayer {
    if (!_successLayer) {
        self.successLayer = [self createLayerWithColor:[UIColor redColor]];
    }
    return _successLayer;
}

- (CAShapeLayer *)failLayer {
    if (!_failLayer) {
        self.failLayer = [self createLayerWithColor:[UIColor yellowColor]];
    }
    return _failLayer;
}
- (CAShapeLayer *)createLayerWithColor:(UIColor *)color {
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.frame = self.bounds;
    layer.lineCap = kCALineCapRound;
    layer.lineJoin = kCALineJoinRound;
    layer.fillColor = nil;
    layer.strokeColor = color.CGColor;
    layer.path = nil;
    layer.lineWidth = 4;
    return layer;
}
- (void)setLineWidth:(CGFloat)lineWidth {
    _circleLayer.lineWidth   = lineWidth;
    _progressLayer.lineWidth = lineWidth;
    _successLayer.lineWidth  = lineWidth;
    _failLayer.lineWidth     = lineWidth;
}




@end