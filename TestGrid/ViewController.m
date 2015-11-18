//
//  ViewController.m
//  TestGrid
//
//  Created by apple on 03/09/15.
//  Copyright (c) 2015 ClickApps. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    CGFloat firstX;
    CGFloat firstY;
    CGRect frameOfTopCard;
    NSMutableArray *colorArray;
}

@property (nonatomic, assign)CGPoint originalPoint;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    colorArray = [[NSMutableArray alloc]initWithCapacity:0];
    [colorArray addObject:[UIColor redColor]];
    [colorArray addObject:[UIColor yellowColor]];
    [colorArray addObject:[UIColor blueColor]];
    [colorArray addObject:[UIColor greenColor]];
    [colorArray addObject:[UIColor grayColor]];
    
    [self createGridWithNumberOfViews:6];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)createGridWithNumberOfViews:(int)numberOfView {
    
    float yPos = 55;
    float sclaleXpos = 1.0;
    float scaleYPos = 1.0;
    float xpos  = 30;
    
    for (int i =0; i<numberOfView; i++) {
        
        UIView *gridView = [[UIView alloc]initWithFrame:CGRectMake(xpos, yPos, self.view.frame.size.width - (xpos *2), self.view.frame.size.width - (xpos *2))];
        gridView.layer.borderWidth = 4.0;
        gridView.layer.borderColor = [UIColor whiteColor].CGColor;
        if (i%2 == 0) {
            gridView.backgroundColor = [UIColor redColor];
        }
        else {
         gridView.backgroundColor = [UIColor yellowColor];
        }
        gridView.layer.cornerRadius = 5.0;
        gridView.layer.shadowOffset = CGSizeMake(0, -2);
        gridView.layer.shadowRadius = 2;
        gridView.layer.shadowOpacity = 0.5;
        gridView.tag = i +1;
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [gridView addGestureRecognizer:panRecognizer];
        
        gridView.userInteractionEnabled = FALSE;
        
        if (i  == numberOfView -1) {
            frameOfTopCard = gridView.frame;
            gridView.userInteractionEnabled = TRUE;
        }

        [contentView addSubview:gridView];
        xpos = xpos - 5;
        yPos = yPos+ 10 ;
        NSLog(@"scaleXpos == %f",sclaleXpos);
        sclaleXpos = sclaleXpos + 0.035;

    }
    
    hgtConstraint.constant = yPos+100;

}


-(void)moveViewOutOfScreen:(UIView *)view toPosition:(CGPoint)point{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.frame = CGRectMake(point.x, point.y, view.frame.size.width, view.frame.size.height);
    } completion:nil];
}


- (void)dragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    
    UIView *vw = [gestureRecognizer view];

    CGFloat xDistance = [gestureRecognizer translationInView:vw].x;
    CGFloat yDistance = [gestureRecognizer translationInView:vw].y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = vw.center;
            break;
        };
        case UIGestureRecognizerStateChanged:{
            CGFloat rotationStrength = MIN(xDistance / 320, 1);
            CGFloat rotationAngel = (CGFloat) (2*M_PI/16 * rotationStrength);
            CGFloat scaleStrength = 1 - fabsf(rotationStrength) / 4;
            CGFloat scale = MAX(scaleStrength, 0.93);
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            vw.transform = scaleTransform;
            vw.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y + yDistance);
            
            
            
            //[self updateOverlay:xDistance];
            break;
        };
        case UIGestureRecognizerStateEnded: {
            
            if (vw.center.x < 0 || vw.center.x > self.view.frame.size.width) {
                
                //move view out of the screen horizontally
                if (vw.center.x < 0) {
                    [self moveViewOutOfScreen:vw toPosition:CGPointMake(-(self.view.frame.size.width *2),  vw.center.y)];
                }
                else {
                    [self moveViewOutOfScreen:vw toPosition:CGPointMake(self.view.frame.size.width+100,  vw.center.y)];
                    
                }
                
                UIView *view = [self.view viewWithTag:vw.tag - 1];
                view.userInteractionEnabled = TRUE;
                frameOfTopCard = view.frame;
                
               
            }
            else if (vw.center.y < 0 || vw.center.y > self.view.frame.size.height) {
                //move view out of the screen vertically
                [self moveViewOutOfScreen:vw toPosition:CGPointMake(vw.center.x,  vw.center.y)];
                frameOfTopCard = [self.view viewWithTag:vw.tag - 1].frame;
            }
            else {

            [self resetViewPositionAndTransformations:vw];
            }
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

- (void)updateOverlay:(CGFloat)distance
{
    NSLog(@"distance == %f",distance);
    
    if (distance > [UIScreen mainScreen].bounds.size.width/2) {
        //move to right of screen
    }
    else if (distance < [UIScreen mainScreen].bounds.size.width/2)
    {
        
    }
    if (distance > 0) {
        //self.overlayView.mode = GGOverlayViewModeRight;
    } else if (distance <= 0) {
       // self.overlayView.mode = GGOverlayViewModeLeft;
    }
   
}

- (void)resetViewPositionAndTransformations:(UIView *)view
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         view.center = self.originalPoint;
                         view.transform = CGAffineTransformMakeRotation(0);
                     }];
}
@end
