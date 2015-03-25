//
//  ViewController.h
//  Knock
//
//  Created by Alexander Hoekje List on 3/24/15.
//  Copyright (c) 2015 Headtalk Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTKnockDetector.h"

@interface ViewController : UIViewController <HTKnockDetectorDelegate>
@property (nonatomic, strong) HTKnockDetector * knockDetector;

@property (nonatomic, strong) IBOutlet UILabel * knockLabel;
@end

