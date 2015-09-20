//
//  HTKnockDetector.m
//  headtalk-ios
//
//  Created by Alexander Hoekje List on 3/12/15.
//  Copyright (c) 2015 Headtalk, Inc. All rights reserved.
//

#import "HTKnockDetector.h"

@interface HTKnockDetector()
-(void)_start;
-(void)_stop;
@end

@implementation HTKnockDetector
-(id) init {
    if (self = [super init]){
        [self tuneAlgorithmToCutoffFrequency:15.0 minimumAcceleration:0.75f minimumKnockSeparation:0.1f];
    }
    return self;
}

-(void)setIsOn:(BOOL)isOn{
    if (isOn != _isOn){
        if (isOn){
            [self _start];
        }else{
            [self _stop];
        }
    }
    _isOn = isOn;
}

-(CMMotionManager*)motionManager{
    if (_motionManager == nil){
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = .01;
    }
    return _motionManager;
}

-(void) tuneAlgorithmToCutoffFrequency:(double)fc minimumAcceleration:(double)minAccel minimumKnockSeparation:(double)separation{
    double delT = self.motionManager.deviceMotionUpdateInterval;
    alg.delT = delT;
    alg.fc = fc;
    
    double RC = 1.0/(2*M_PI*fc);
    double alpha = RC/ (RC + delT);
    alg.alpha = alpha;
    
    alg.minAccel = minAccel;
    alg.minKnockSeparation = separation;
}

-(void) processNextMotion:(CMDeviceMotion*)motion{
    double newZ = [motion userAcceleration].z;
    alg.Xim1    = alg.Xi;
    alg.Xi      = newZ;
    
    alg.Yim1    = alg.Yi;
    alg.Yi = alg.alpha*alg.Yim1 + alg.alpha*(alg.Xi-alg.Xim1);
    
    if (fabs(alg.Yi) > alg.minAccel){
        if (fabs(alg.lastKnock - motion.timestamp) > alg.minKnockSeparation){
            alg.lastKnock = motion.timestamp;
            [self.delegate knockDetectorDetectedKnock:self atTime:motion.timestamp];
        }
    }
}

-(void)_start{
    HTKnockDetector * __weak weakSelf = self;
    if (self.motionManager.deviceMotionAvailable) {
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
             withHandler:^(CMDeviceMotion *data, NSError *error) {
                 [weakSelf processNextMotion:data];
             }];
    }
}

-(void)_stop{
    [self.motionManager stopDeviceMotionUpdates];
}
@end
