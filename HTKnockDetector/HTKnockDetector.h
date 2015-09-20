//
//  HTKnockDetector.h
//  headtalk-ios
//
//  Created by Alexander Hoekje List on 3/12/15.
//  Copyright (c) 2015 Headtalk, Inc. All rights reserved.
//

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

/// A simple detector for physical knocks, tuned for the Z-axis of iPhone 5s and 6 devices. Just set `delegate` and `isOn` to receive Knock events.
///
/// HTKnockDetector can even run in background, depending on your background modes! You will need to set `isOn = false`, and then `isOn = true` after backgrounding for Core Motion to send the detector events during background operation.

@interface HTKnockDetector : NSObject{
    hpf alg;
}

@property (nonatomic, weak) id<HTKnockDetectorDelegate> delegate;
@property (nonatomic, assign) BOOL isOn;

/**
 Tunes algorithm.
 @param fc The cutoff frequency for the algorithm. Default 15.0. The frequency of an average knock is 20, as the maximum interval of the knocks I saw in tests was .05s. At 15, it slightly overdetects, at 20 it underdetects, which I bet would get people to conform to the algorithm if they have feedback.
  @param minAccel The minimum acceleration to trigger a knock event. Default 0.75f(G).
  @param separation The minimum time separation between detected knock events. Default 0.1f(s).
 */
-(void) tuneAlgorithmToCutoffFrequency:(double)fc minimumAcceleration:(double)minAccel minimumKnockSeparation:(double)separation;

///the accelerometer, a protected property, exposed here for Mock testing
@property (nonatomic, strong) CMMotionManager * motionManager;
@end
