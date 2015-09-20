//
//  ViewController.m
//  Knock
//
//  Created by Alexander Hoekje List on 3/24/15.
//  Copyright (c) 2015 Headtalk Inc. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
-(void)knockDetectorDetectedKnock:(HTKnockDetector*)detector atTime:(NSTimeInterval)time{
    self.knockLabel.alpha = 1;
    [UIView animateWithDuration:.6 delay:.1 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseOut animations:^{
        self.knockLabel.alpha = 0;
    } completion:nil];
    
    NSLog(@"Knock detected! at time %f", time);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.knockDetector = [[HTKnockDetector alloc] init];
    [self.knockDetector setDelegate:self];
    [self.knockDetector setIsOn:true];
    
    self.knockLabel.alpha = 0;
}
@end
