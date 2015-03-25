//
//  HTKnockDetectorTest.m
//  headtalk-ios
//
//  Created by Alexander Hoekje List on 3/13/15.
//  Copyright (c) 2015 Headtalk, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "HTKnockDetector.h"
#import <CoreMotion/CoreMotion.h>

@interface HTKnockDetectorTest : XCTestCase <HTKnockDetectorDelegate>
@property (nonatomic, strong) HTKnockDetector * knockDetector;
@property (nonatomic, strong) NSMutableArray* detectedKnocks;

@end

@implementation HTKnockDetectorTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    self.knockDetector = nil;
    self.detectedKnocks = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
}

-(NSArray*)deviceMotionMocksForDataInCSVNamed:(NSString*)csvName{
    
    NSString * path = [[NSBundle bundleForClass:[self class]]pathForResource:csvName ofType:@"csv"];
    NSString * csv = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    XCTAssert(csv);
    static NSString * rowDelimiter      = @"\n";
    static NSString * elementDelimiter  = @",";
    NSArray * rows = [csv componentsSeparatedByString:rowDelimiter];
    XCTAssert(rows.count > 0);
    
    NSMutableArray * motionMocks = [[NSMutableArray alloc] init];
    Class deviceMotion = [CMDeviceMotion class];
    for (NSString * row in rows){
        NSArray * timeThenAccelValueArray = [row componentsSeparatedByString:elementDelimiter];
        if (timeThenAccelValueArray.count < 2){
            break;//end of file newline
        }
        
        double timestamp        = [[timeThenAccelValueArray objectAtIndex:0] doubleValue];
        double zAcceleration    = [[timeThenAccelValueArray objectAtIndex:1] doubleValue];
        CMAcceleration accel = {0,0,zAcceleration};
        
        OCMockObject * motionMock = [OCMockObject mockForClass:deviceMotion];
        
        [[[motionMock stub] andReturnValue:OCMOCK_VALUE(accel)] userAcceleration];
        [[[motionMock stub] andReturnValue:OCMOCK_VALUE(timestamp)] timestamp];

        [motionMocks addObject:motionMock];
    }
    
    
    return motionMocks;
}

-(void)testDoesUtilizeUpdateInterval{
    self.knockDetector      = [[HTKnockDetector alloc] init];
    [self.knockDetector setDelegate:self];
    
    CMMotionManager * motionManager = [[CMMotionManager alloc] init];
    id motionManagerMock  = [OCMockObject partialMockForObject:motionManager];
    [self.knockDetector setMotionManager:motionManagerMock];
    [self.knockDetector setIsOn:true];
    OCMVerify([motionManagerMock deviceMotionUpdateInterval]);
}

-(id)motionManagerMockWithDataCSVNamed:(NSString*)csvName{
    
    NSArray * motionMocks = [self deviceMotionMocksForDataInCSVNamed:csvName];
    
    id motionManagerMock  = [OCMockObject mockForClass:[CMMotionManager class]];
    [[[motionManagerMock stub] andReturnValue:OCMOCK_VALUE(.01)] deviceMotionUpdateInterval];
    [[[motionManagerMock stub] andReturnValue:OCMOCK_VALUE(true)] isDeviceMotionAvailable];
    
    
    void (^proxyBlock)(NSInvocation *) = ^void(NSInvocation * invocation) {
        CMDeviceMotionHandler deviceMotionHandler = nil;
        [invocation getArgument:&deviceMotionHandler atIndex:3];
        
        XCTAssert(deviceMotionHandler != nil);
        
        for (OCMockObject * motion in motionMocks){
            deviceMotionHandler((id)motion, nil); //on main queue

        }
        
    };
    
    [[[motionManagerMock stub] andDo:proxyBlock] startDeviceMotionUpdatesToQueue:OCMOCK_ANY withHandler:OCMOCK_ANY];
    
    return motionManagerMock;
}


-(void) knockDetectorDetectedKnock:(HTKnockDetector *)detector atTime:(NSTimeInterval)time{
    [self.detectedKnocks addObject:@(time).stringValue];
}

-(NSUInteger)countKnocksForCSVNamed:(NSString*)csvName{
    self.knockDetector      = [[HTKnockDetector alloc] init];
    [self.knockDetector setDelegate:self];
    self.detectedKnocks = [NSMutableArray array];
    
    @autoreleasepool {
        id motionManagerMock  = [self motionManagerMockWithDataCSVNamed:csvName];
        [self.knockDetector setMotionManager:motionManagerMock];
        [self.knockDetector setIsOn:true];
    }
    
    NSLog(@"CSV: %@ yields-> %@",csvName, [self.detectedKnocks description]);
    
    return self.detectedKnocks.count;
}

#define KnocksInCSV(variable) [self countKnocksForCSVNamed:variable]

-(void)testDetectsPocketKnocksOnBack {
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"pocketKnocksBack6-4"), 4, 0);
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"pocketKnocksBack6-5"), 5, 0);
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"pocketKnocksBack6-6"), 6, 0);

    XCTAssertEqualWithAccuracy(KnocksInCSV(@"pocketKnocksBackFrontPocket6-6"), 6, 0);
}

-(void)testDetectsPocketKnocksOnFront {
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"pocketKnocksFront6-10"), 10, 0);
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"pocketKnocksFront6-5"), 5, 0);
}

-(void)testDetectsHeldKnocksOnBack {
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"heldKnocksBack6-10"), 10, 0);
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"heldKnocksBack6-3"), 3, 0);
}

-(void)testDetectsHeldKnocksOnFront {
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"heldKnocksFront6-12"), 12, 0);
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"heldKnocksFront6-3"), 3, 0);
}

-(void)testAgnosticTableKnocksOnBack {
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"tableKnocksBack6-5"), 5, 5);
}

-(void)testAgnosticTableKnocksOnFront {
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"tableKnocksFront6-20"), 12, 12);
}

-(void)testIgnoresTablePlace{
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"heldTablePlaceFront6"), 0, 0);
}

-(void)testIgnoresHeldRandomMotion {
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"heldRandomWave6"), 0, 0);
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"heldRandomShake6"), 0, 0);
}

-(void)testIgnoresHeldPokes {
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"heldPokesFront6"), 0, 0);
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"heldPokesBack6"), 0, 0);
}

-(void)testIgnoresPocketRandomMotion {
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"pocketRandomShakeBack6"), 0, 0);
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"pocketRandomSquatBack6"), 0, 0);
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"pocketRandomArmsStairsBack6"), 0, 0);
}

-(void)testIgnoresPocketPokes {
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"pocketPokesFront6"), 0, 0);
    XCTAssertEqualWithAccuracy(KnocksInCSV(@"pocketPokesBack6"), 0, 0);
}


//-(void) testWhatHappensIfActualTimeIntervalChanges;//;)

@end
