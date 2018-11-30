//
//  XLDouYinLoading.m
//  XLDouYinLoadingDemo
//
//  Created by MengXianLiang on 2018/11/28.
//  Copyright © 2018 JWZT. All rights reserved.
//

#import "XLDouYinLoading.h"

//球宽
static CGFloat BallWidth = 12.0f;

//球速
static CGFloat BallSpeed = 0.7f;

//球缩放比例
static CGFloat BallZoomScale = 0.25;

//暂停时间 s
static CGFloat PauseSecond = 0.18;


//球的运动方向，以绿球向右、红球向左运动为正向，
typedef NS_ENUM(NSInteger, BallMoveDirection) {
    //正向
    BallMoveDirectionPositive = 1,
    //逆向
    BallMoveDirectionNegative = -1,
};

@interface XLDouYinLoading ()

//球的容器
@property (nonatomic, strong) UIView *ballContainer;
//绿球
@property (nonatomic, strong) UIView *greenBall;
//红球
@property (nonatomic, strong) UIView *redBall;
//黑球
@property (nonatomic, strong) UIView *blackBall;
//移动方向
@property (nonatomic, assign) BallMoveDirection ballMoveDirection;
//刷新器
@property (nonatomic, strong) CADisplayLink *displayLink;
//开始动画
- (void)startAnimated;
//停止动画
- (void)stopAnimated;

@end

@implementation XLDouYinLoading

#pragma mark -
#pragma mark 显示/隐藏方法

+ (instancetype)showInView:(UIView *)view {
    XLDouYinLoading *loading = [[XLDouYinLoading alloc] initWithFrame:view.bounds];
    [view addSubview:loading];
    [loading startAnimated];
    return loading;
}

+ (BOOL)hideInView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            XLDouYinLoading *loading = (XLDouYinLoading *)subview;
            [loading stopAnimated];
            [loading removeFromSuperview];
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark 初始化方法

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
    }
    return self;
}

#pragma mark -
#pragma mark 动画相关

- (void)buildUI {
    self.ballContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2.1*BallWidth, 2*BallWidth)];
    self.ballContainer.center = [self center];
    [self addSubview:self.ballContainer];
    
    self.greenBall = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BallWidth, BallWidth)];
    self.greenBall.center = CGPointMake(BallWidth/2.0f, self.ballContainer.bounds.size.height/2.0f);
    self.greenBall.layer.cornerRadius = BallWidth/2.0f;
    self.greenBall.layer.masksToBounds = true;
    self.greenBall.backgroundColor = [UIColor colorWithRed:35/255.0f green:246/255.0f blue:235/255.0f alpha:1];
    [self.ballContainer addSubview:self.greenBall];
    
    self.redBall = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BallWidth, BallWidth)];
    self.redBall.center = CGPointMake(self.ballContainer.bounds.size.width - BallWidth/2.0f, self.ballContainer.bounds.size.height/2.0f);
    self.redBall.layer.cornerRadius = BallWidth/2.0f;
    self.redBall.layer.masksToBounds = true;
    self.redBall.backgroundColor = [UIColor colorWithRed:255/255.0f green:46/255.0f blue:86/255.0f alpha:1];
    [self.ballContainer addSubview:self.redBall];
    
    //第一次动画是正向，绿球在上，红球在下，阴影会显示在绿球上
    self.blackBall = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BallWidth, BallWidth)];
    self.blackBall.backgroundColor = [UIColor colorWithRed:12/255.0f green:11/255.0f blue:17/255.0f alpha:1];
    self.blackBall.layer.cornerRadius = BallWidth/2.0f;
    self.blackBall.layer.masksToBounds = true;
    [self.greenBall addSubview:self.blackBall];
    
    //初始化方向是正向
    self.ballMoveDirection = BallMoveDirectionPositive;
    //初始化刷新方法
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateBallAnimations)];
}

- (void)startAnimated {
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopAnimated {
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)pauseAnimated {
    [self stopAnimated];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PauseSecond*NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [self startAnimated];
    });
}

- (void)updateBallAnimations {
    if (self.ballMoveDirection == BallMoveDirectionPositive) {//正向运动
        //更新绿球位置
        CGPoint center = self.greenBall.center;
        center.x += BallSpeed;
        self.greenBall.center = center;
        
        //更新红球位置
        center = self.redBall.center;
        center.x -= BallSpeed;
        self.redBall.center = center;
        
        //缩放动画,绿球放大 红球变小
        self.greenBall.transform = [self ballLargerTransformOfCenterX:center.x];
        self.redBall.transform = [self ballSmallerTransformOfCenterX:center.x];
        
        //更新黑球位置
        CGRect blackBallFrame = [self.redBall convertRect:self.redBall.bounds toCoordinateSpace:self.greenBall];
        self.blackBall.frame = blackBallFrame;
        self.blackBall.layer.cornerRadius = self.blackBall.bounds.size.width/2.0f;
        
        //更新方向+改变三个球的相对位置
        if (CGRectGetMaxX(self.greenBall.frame) >= self.ballContainer.bounds.size.width || CGRectGetMinX(self.redBall.frame) <= 0) {
            //切换为反向
            self.ballMoveDirection = BallMoveDirectionNegative;
            //反向运动时，红球在上，绿球在下
            [self.ballContainer bringSubviewToFront:self.redBall];
            //黑球放在红球上面
            [self.redBall addSubview:self.blackBall];
            //暂停一下
            [self pauseAnimated];
        }
    }else if (self.ballMoveDirection == BallMoveDirectionNegative) {//反向运动
        //更新绿球位置
        CGPoint center = self.greenBall.center;
        center.x -= BallSpeed;
        self.greenBall.center = center;
        
        //更新红球位置
        center = self.redBall.center;
        center.x += BallSpeed;
        self.redBall.center = center;
        
        //缩放动画,红球放大 绿/黑球变小
        self.redBall.transform = [self ballLargerTransformOfCenterX:center.x];
        self.greenBall.transform = [self ballSmallerTransformOfCenterX:center.x];
        
        //更新黑球位置
        CGRect blackBallFrame = [self.greenBall convertRect:self.greenBall.bounds toCoordinateSpace:self.redBall];
        self.blackBall.frame = blackBallFrame;
        self.blackBall.layer.cornerRadius = self.blackBall.bounds.size.width/2.0f;
        
        //更新方向+改变三个球的相对位置
        if (CGRectGetMinX(self.greenBall.frame) <= 0 || CGRectGetMaxX(self.redBall.frame) >= self.ballContainer.bounds.size.width) {
            //切换为正向
            self.ballMoveDirection = BallMoveDirectionPositive;
            //正向运动时，绿球在上，红球在下
            [self.ballContainer bringSubviewToFront:self.greenBall];
            //黑球放在绿球上面
            [self.greenBall addSubview:self.blackBall];
            //暂停动画
            [self pauseAnimated];
        }
    }
}


//放大动画
- (CGAffineTransform)ballLargerTransformOfCenterX:(CGFloat)centerX {
    CGFloat cosValue = [self cosValueOfCenterX:centerX];
    return CGAffineTransformMakeScale(1 + cosValue*BallZoomScale, 1 + cosValue*BallZoomScale);
}

//缩小动画
- (CGAffineTransform)ballSmallerTransformOfCenterX:(CGFloat)centerX {
    CGFloat cosValue = [self cosValueOfCenterX:centerX];
    return CGAffineTransformMakeScale(1 - cosValue*BallZoomScale, 1 - cosValue*BallZoomScale);
}

//根据余弦函数获取变化区间 变化范围是0~1~0
- (CGFloat)cosValueOfCenterX:(CGFloat)centerX {
    CGFloat apart = centerX - self.ballContainer.bounds.size.width/2.0f;
    //最大距离(球心距离Container中心距离)
    CGFloat maxAppart = (self.ballContainer.bounds.size.width - BallWidth)/2.0f;
    //移动距离和最大距离的比例
    CGFloat angle = apart/maxAppart*M_PI_2;
    //获取比例对应余弦曲线的Y值
    return cos(angle);
}

@end
