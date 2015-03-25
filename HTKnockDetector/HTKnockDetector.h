//
//  HTKnockDetector.h
//  headtalk-ios
//
//  Created by Alexander Hoekje List on 3/12/15.
//  Copyright (c) 2015 Headtalk, Inc. All rights reserved.
//

//TODO:
//1) Make sure adapts to changes in actual detection time
//Why? Because samples are not guaranteed to come in at the speicified spacing

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

typedef struct{
    double alpha;
    double Yi;
    double Yim1;
    double Xi;
    double Xim1;

    double delT;
    double fc; //cutoff frequency
    
    double minAccel;
    NSTimeInterval minKnockSeparation;
    NSTimeInterval lastKnock;
}hpf;


@class HTKnockDetector;

@protocol HTKnockDetectorDelegate <NSObject>
-(void)knockDetectorDetectedKnock:(HTKnockDetector*)detector atTime:(NSTimeInterval)time;
@end

@interface HTKnockDetector : NSObject{
    hpf alg;
}

@property (nonatomic, weak) id<HTKnockDetectorDelegate> delegate;
//accelerometer, a private property
@property (nonatomic, strong) CMMotionManager * motionManager;
@property (nonatomic, assign) BOOL isOn;
@end
