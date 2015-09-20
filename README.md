## *HTKnockDetector*. A simple detector for physical knocks on the back or front of an iPhone. Tuned for the Z-axis of iPhone 5s and 6 devices. Just set `delegate` and `isOn` to receive Knock events.

*Written by Alex List, Headtalk Inc, Spring 2015. License– bottom of document.*

###Quick start
1. Drag `HTKnockDetector.h`, `HTKnockDetector.m` into your project.
2. Import `CoreMotion.framework` into your project.
3. Initialize HTKnockDetector and run
``` Obj-C   
self.knockDetector = [[HTKnockDetector alloc] init];
[self.knockDetector setDelegate:self];
[self.knockDetector setIsOn:true];
```

####Background operation
HTKnockDetector can even run in background, depending on your background modes! You will need to set `isOn = false`, and then `isOn = true` after backgrounding for Core Motion to send the detector events during background operation.

###How it works.

1. Z-Axis, into the screen, data comes in via "device motion" on iOS. This is user motion, with gravity subtracted.
2. A high-pass filter is applied.
3. I look for high intensity values, for example .75G or up.
4. If a minimum time separation since the last knock has occurred, a knock is detected.

###Testing.
`KnockTests/TestData` contains suite of test data, me doing various active activities and *knocking* on my iPhone 6.

Data are all CSVs with format *[time in seconds, Z-Axis acceleration in Gs]*. Where the `testName-#.csv` file name contains an "-", then the test included "#" knocks.

Run the `XCode tests` in `Knock.xcodeproj` by going to **Product > Test**.


###TODO.
1. **Reflect variable sampling rate in algorithm.** *Data from Core Motion is not guaranteed to be equally spaced in time. This is especially problematic in background modes, and when resuming from background.* An update would actually use the time spacing returned with data.

2. **Fix testing style.** *Many tests do not pass, but instead verbosely print the number of missed knocks.* A `performance`-type test would be more appropriate. One solution with `XCTest` is using `[self measureBlock]` with `testPerformance` cases, in which time delays are invoked for missed Knocks, indicating performance without *failing*.

###Important.
Different platforms (Android vs iOS) and form factors (Watch, Tablet, etc) will have different acceleration values for similar knocks. You may need to determine the frequency and acceleration of knocks on those platforms. 

###Dependencies.
The test suite relies on OCMock, a 3rd party framework included in this project.

The framework requires CoreMotion.framework, by Apple.

###License.

The MIT License (MIT)

Copyright (c) 2015 Headtalk Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
