#define CartesianToCompass(rad) ((rad) + M_PI / 2 )
#define CompassToCartesian(rad) ((rad) - M_PI / 2 )

#import "CHcir_Slider.h"
///角度转弧度
static inline double DegreesToRadians(double angle) { return M_PI * angle / 180.0; }
///弧度转角度
static inline double RadiansToDegrees(double angle) { return angle * 180.0 / M_PI; }

static inline CGPoint CGPointCenterRadiusAngle(CGPoint c, double r, double a) {
    return CGPointMake(c.x + r * cos(a), c.y + r * sin(a));
}

static inline CGFloat AngleBetweenPoints(CGPoint a, CGPoint b, CGPoint c) {
    return atan2(a.y - c.y, a.x - c.x) - atan2(b.y - c.y, b.x - c.x);
}

@interface CHcir_Slider ()

@property (strong, nonatomic) CALayer *outerCircleLayer;

@property (assign, nonatomic) CGPoint handcenterPoint ;

@property (assign, nonatomic) CGPoint handcenterPoint1 ;

@property (assign, nonatomic) CGPoint location;

@end

@implementation CHcir_Slider
- (instancetype)init
{
    return [self initWithFrame:CGRectZero] ;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _startAngle = -90.f;
        _cutoutAngle = 90.f;
        _lineWidth = 40.f;
        _guideLineColor = [UIColor clearColor];
        _progress = 1.f;
        _progress1 = .0f;
        _handleOutSideRadius = 10.f;
        _handleInSideRadius = 4.f;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}


//检测触摸点是否在slider所在圆圈范围内
- (BOOL)pointInsideCircle:(CGPoint)point {
    CGPoint p1 =  CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGPoint p2 = point;
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    double distance = sqrt((xDist * xDist) + (yDist * yDist));
    CGFloat radius = CGRectGetMidX(self.bounds) - self.lineWidth / 2 - self.handleOutSideRadius *2 ;
    
    
    CGFloat handleRadius = self.handleOutSideRadius;
    
    return distance < radius + self.lineWidth * 0.5 + handleRadius && distance > radius - self.lineWidth *0.5 - handleRadius;
}

//检测触摸点是否在滑动块中
- (BOOL)pointInsideHandle:(CGPoint)point{
    CGPoint handleCenter = CGPointMake(_handcenterPoint.x, self.bounds.size.width- _handcenterPoint.y) ;
  //   NSLog(@"(%f..%f)......(%f..%f).......(%f..%f)",_handcenterPoint.x,_handcenterPoint.y,handleCenter.x,handleCenter.y,point.x,point.y);
    CGFloat handleRadius = _handleOutSideRadius+30;
    
    CGRect handleRect = CGRectMake(handleCenter.x - handleRadius, handleCenter.y - handleRadius, handleRadius * 2, handleRadius * 2);
    return CGRectContainsPoint(handleRect, point);
}


- (BOOL)point1InsideHandle:(CGPoint)point{
    CGPoint handleCenter = CGPointMake(_handcenterPoint1.x, self.bounds.size.width- _handcenterPoint1.y) ;

    CGFloat handleRadius = _handleOutSideRadius+30;
    
    CGRect handleRect = CGRectMake(handleCenter.x - handleRadius, handleCenter.y - handleRadius, handleRadius * 2, handleRadius * 2);
    return CGRectContainsPoint(handleRect, point);
}



- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    _location = [touch locationInView:self];
    if([self pointInsideHandle:_location] == 1){
        [self drawWithLocation:_location with:1];
    }
    else if([self point1InsideHandle:_location] == 1){
        [self drawWithLocation:_location with:2];
    }
    
    return YES;
}
- (void)drawWithLocation:(CGPoint)location with:(NSInteger)index{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = CGRectGetMidX(self.bounds) - self.lineWidth / 2;
    CGFloat startAngle = _startAngle;
    if (startAngle < 0)
        startAngle = fabs(startAngle);
    else
        startAngle = 360.f - startAngle;
    CGPoint startPoint = CGPointCenterRadiusAngle(center, radius, DegreesToRadians(startAngle));
    CGFloat angle = RadiansToDegrees(AngleBetweenPoints(location, startPoint, center));
    if (angle < 0) angle += 360.f;
    angle = angle - _cutoutAngle / 2.f;
    
    if(index == 1)
        self.progress = angle / (360.f - _cutoutAngle);
    else if(index == 2)
        self.progress1 = angle/ (360.f - _cutoutAngle);
    
    [self.delegate maxIntValueChanged:self.progress];
    [self.delegate minIntValueChanged:self.progress1];

}
- (void)setStartAngle:(CGFloat)startAngle {
    _startAngle = startAngle;
    [self setNeedsDisplay];
}

- (void)setCutoutAngle:(CGFloat)cutoutAngle {
    _cutoutAngle = cutoutAngle;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress {
    if (progress > 0.99)
        _progress = 0.99;
    else if (progress < 0)
        _progress = 0;
    else
        _progress = progress;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
}

- (void)setProgress1:(CGFloat)progress1{
    if (progress1 > 1)
        _progress1 = 1;
    else if (progress1 < 0.01)
        _progress1 = 0.01;
    else
        _progress1 = progress1;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height); //改变画布位置（0，0位置移动到此处）
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetLineWidth(context, self.lineWidth);
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = CGRectGetMidX(self.bounds) - self.lineWidth / 2 - self.handleOutSideRadius *2 ;
    CGFloat arcStartAngle = DegreesToRadians(self.startAngle + 360.0 - self.cutoutAngle / 2.0);
    CGFloat arcEndAngle = DegreesToRadians(self.startAngle + self.cutoutAngle / 2.0);
    CGFloat progressAngle = DegreesToRadians(360.f - self.cutoutAngle) * self.progress;
    
    CGFloat progressAngle1 = DegreesToRadians(360.f - self.cutoutAngle) * _progress1;
    
    [self.guideLineColor set];
    CGContextAddArc(context, center.x, center.y, radius, arcStartAngle, arcEndAngle, 1);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextStrokePath(context);
    
    [self.tintColor set];
    CGContextAddArc(context, center.x, center.y, radius, arcStartAngle, arcStartAngle - progressAngle, 1);
    CGContextStrokePath(context);
    
    [[UIColor orangeColor]set];
    CGContextAddArc(context, center.x, center.y, radius, arcStartAngle, arcStartAngle - progressAngle1, 1);
    CGContextStrokePath(context);
    
    
    [[UIColor whiteColor] set];
    CGContextSetLineWidth(context, self.handleOutSideRadius * 2);
    CGPoint handle = CGPointCenterRadiusAngle(center, radius, arcStartAngle - progressAngle);
    CGContextAddArc(context, handle.x, handle.y, self.handleOutSideRadius, 0, DegreesToRadians(360), 1);
    CGContextStrokePath(context);
    _handcenterPoint = handle;
    
    
    [self.tintColor set];
    CGContextSetLineWidth(context, self.handleInSideRadius * 2);
    CGContextAddArc(context, handle.x, handle.y, self.handleInSideRadius, 0, DegreesToRadians(360), 1);
    CGContextStrokePath(context);
    
    
    [[UIColor whiteColor] set];
    CGContextSetLineWidth(context, self.handleOutSideRadius * 2);
    CGPoint handle1 = CGPointCenterRadiusAngle(center, radius, arcStartAngle - progressAngle1);
    _handcenterPoint1 = handle1;
    CGContextAddArc(context, handle1.x, handle1.y, self.handleOutSideRadius, 0, DegreesToRadians(360), 1);
    CGContextStrokePath(context);
    
    [[UIColor orangeColor] set];
    CGContextSetLineWidth(context, self.handleInSideRadius * 2);
    CGContextAddArc(context, handle1.x, handle1.y, self.handleInSideRadius, 0, DegreesToRadians(360), 1);
    CGContextStrokePath(context);
    

    
}

@end
