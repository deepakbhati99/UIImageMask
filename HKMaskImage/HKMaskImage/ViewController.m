//
//  ViewController.m
//  HKMaskImage
//
//  Created by Himanshu Khatri on 3/2/16.
//  Copyright © 2016 bdAppManiac. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIGestureRecognizerDelegate>
{
     UIBezierPath *path;
    CALayer *drawLayer;
     UIImage *incrementalImage; // (1)
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

/*@property (nonatomic) CGFloat circleRadius;
@property (nonatomic) CGPoint circleCenter;

@property (nonatomic, weak) CAShapeLayer *maskLayer;
@property (nonatomic, weak) CAShapeLayer *circleLayer;

@property (nonatomic, weak) UIPinchGestureRecognizer *pinch;
@property (nonatomic, weak) UIPanGestureRecognizer   *pan;*/

@end

@implementation ViewController



/*To save the masked image, in iOS 7 you'd use drawViewHierarchyInRect, and in earlier versions of iOS, you'd use renderInContext. You might also want to crop the image with CGImageCreateWithImageInRect. See my didTouchUpInsideSaveButton below for an example.

But I note that you are apparently masking by overlaying an image. I might suggest using a UIBezierPath for the basis of both a layer mask for the image view, as well as the CAShapeLayer you'll use to draw the circle (assuming you want a border as you draw the circle. If your mask is a regular shape (such as a circle), it's probably more flexible to make it a CAShapeLayer with a UIBezierPath (rather than an image), because that way you can not only move it around with a pan gesture, but also scale it, too, with a pinch gesture:

enter image description here

Here is a sample implementation:*/


- (void)viewDidLoad
{
    [super viewDidLoad];
    path = [UIBezierPath bezierPath];
    drawLayer = [[CALayer alloc] init];
    drawLayer.frame = CGRectMake(0.0f, 0.0f, self.view.layer.frame.size.width, self.view.layer.frame.size.height);

    [path setLineWidth:2.0];
}
- (void) layoutSubviews
{
    drawLayer.frame = CGRectMake(0.0f, 0.0f, self.view.layer.frame.size.width, self.view.layer.frame.size.height);
}
- (void) drawLineFrom:(CGPoint)from to:(CGPoint)to width:(CGFloat)width
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(ctx, 1.0f, -1.0f);
    CGContextTranslateCTM(ctx, 0.0f, -self.view.frame.size.height);
    if (incrementalImage != nil) {
        CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
        CGContextDrawImage(ctx, rect, incrementalImage.CGImage);
    }
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, width);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextMoveToPoint(ctx, from.x, from.y);
    CGContextAddLineToPoint(ctx, to.x, to.y);
    CGContextStrokePath(ctx);
    CGContextFlush(ctx);
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    drawLayer.contents = (id)incrementalImage.CGImage;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self isTouchOnImageView:touches withEvent:event]) {
        UITouch *touch = [touches anyObject];
        CGPoint p = [touch locationInView:self.view];
        [path moveToPoint:p];
    }

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self isTouchOnImageView:touches withEvent:event]) {
        UITouch *touch = [touches anyObject];
        CGPoint p = [touch locationInView:self.imageView];
        [path addLineToPoint:p];
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event // (2)
{
    if ([self isTouchOnImageView:touches withEvent:event]) {
        UITouch *touch = [touches anyObject];
        CGPoint p = [touch locationInView:self.imageView];
        [path addLineToPoint:p];
        [self drawBitmap]; // (3)
//        [path removeAllPoints]; //(4)
    }

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawBitmap // (3)
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.0);
    [[UIColor blackColor] setStroke];
    if (!incrementalImage) // first draw; paint background white by ...
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.view.bounds]; // enclosing bitmap by a rectangle defined by another UIBezierPath object
        [[UIColor whiteColor] setFill];
        [rectpath fill]; // filling it with white
    }
    [incrementalImage drawAtPoint:CGPointZero];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
-(BOOL)isTouchOnImageView:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    CGPoint viewPoint = [self.imageView convertPoint:locationPoint fromView:self.view];

    return [self.imageView pointInside:viewPoint withEvent:event];
}
/*    // create layer mask for the image
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    self.imageView.layer.mask = maskLayer;
    self.maskLayer = maskLayer;
    
    // create shape layer for circle we'll draw on top of image (the boundary of the circle)
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.lineWidth = 3.0;
    circleLayer.fillColor = [[UIColor clearColor] CGColor];
    circleLayer.strokeColor = [[UIColor blackColor] CGColor];
    [self.imageView.layer addSublayer:circleLayer];
    self.circleLayer = circleLayer;
    
    // create circle path
    
    [self updateCirclePathAtLocation:CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0) radius:self.view.bounds.size.width * 0.30];
    
    // create pan gesture
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.imageView addGestureRecognizer:pan];
    self.imageView.userInteractionEnabled = YES;
    self.pan = pan;
    
    // create pan gesture
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    self.pinch = pinch;
}

- (void)updateCirclePathAtLocation:(CGPoint)location radius:(CGFloat)radius
{
    self.circleCenter = location;
    self.circleRadius = radius;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:self.circleCenter
                    radius:self.circleRadius
                startAngle:0.0
                  endAngle:M_PI * 2.0
                 clockwise:YES];
    
    self.maskLayer.path = [path CGPath];
    self.circleLayer.path = [path CGPath];
}

- (IBAction)didTouchUpInsideSaveButton:(id)sender
{
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"image.png"];
    
    CGFloat scale  = [[self.imageView.window screen] scale];
    CGFloat radius = self.circleRadius * scale;
    CGPoint center = CGPointMake(self.circleCenter.x * scale, self.circleCenter.y * scale);
    
    CGRect frame = CGRectMake(center.x - radius,
                              center.y - radius,
                              radius * 2.0,
                              radius * 2.0);
    
    // temporarily remove the circleLayer
    
    CALayer *circleLayer = self.circleLayer;
    [self.circleLayer removeFromSuperlayer];
    
    // render the clipped image
    
    UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ([self.imageView respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        // if iOS 7, just draw it
        
        [self.imageView drawViewHierarchyInRect:self.imageView.bounds afterScreenUpdates:YES];
    }
    else
    {
        // if pre iOS 7, manually clip it
        
        CGContextAddArc(context, self.circleCenter.x, self.circleCenter.y, self.circleRadius, 0, M_PI * 2.0, YES);
        CGContextClip(context);
        [self.imageView.layer renderInContext:context];
    }
    
    // capture the image and close the context
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // add the circleLayer back
    
    [self.imageView.layer addSublayer:circleLayer];
    
    // crop the image
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], frame);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    
    // save the image
    
    NSData *data = UIImagePNGRepresentation(croppedImage);
    [data writeToFile:path atomically:YES];
    
    // tell the user we're done
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Saved" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}


#pragma mark - Gesture recognizers

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    static CGPoint oldCenter;
    CGPoint tranlation = [gesture translationInView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        oldCenter = self.circleCenter;
    }
    
    CGPoint newCenter = CGPointMake(oldCenter.x + tranlation.x, oldCenter.y + tranlation.y);
    
    [self updateCirclePathAtLocation:newCenter radius:self.circleRadius];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    static CGFloat oldRadius;
    CGFloat scale = [gesture scale];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        oldRadius = self.circleRadius;
    }
    
    CGFloat newRadius = oldRadius * scale;
    
    [self updateCirclePathAtLocation:self.circleCenter radius:newRadius];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ((gestureRecognizer == self.pan   && otherGestureRecognizer == self.pinch) ||
        (gestureRecognizer == self.pinch && otherGestureRecognizer == self.pan))
    {
        return YES;
    }
    
    return NO;
}*/


@end
