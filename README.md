Written by Alex List, Spring 2015
Headtalk Inc All right reserved 
Write hi@headtalk.io for express licensing

For all licensed parties, code is provided AS IS with NO WARRANTEE 
This is not production code, THERE ARE BUGS
YOU ARE RESPONISBLE FOR ALL RISKS AND LIABILITIES ASSOCIATED WITH THIS CODE

Okay, so now down to the how it works:
Data comes in via "device motion" on iOS -- essentially user motion with gravity subtracted – I only care about the Z-direction 
(see http://nshipster.com/cmdevicemotion/)
I discovered that the intense part of a knock generally happens in under .05 seconds, so I implemented a high pass filter with cutoffFrequency= 1.0/.05 to only see "knock-like" actions
(See http://en.wikipedia.org/wiki/High-pass_filter#Algorithmic_implementation)

Then I look for high intensity values along one axis, fabs(filteredValue) >= .75G <minAccel>, 
if so, and if a time delay <minKnockSeparation> has occured since the last activation, the knock is detected


Testing:
I built a suite of test data of me doing various activities– you'll find them in KnockTests/TestData 
These are all CSVs with [time in seconds, Z-Axis accleration in Gs] as the data format

Specificially important, if the testName-#.csv file name contains an "-", then the test included "#" knocks. 

Important: I did not know how best to handle testing real world data, so many tests do not pass. That's okay, you can use the suite to subjectively verify that your use case is appropiately implemented. 
TODO: Create some accuracy metric to help developers, vs arbitrary test pass/failure.

Important: Different platforms (Android vs iOS) and form factors (Watch, Tablet, etc) will have different acceleration values. You should create a new test suite of CSV files for various behaviors you care about.

Dependencies: 
The test suite relies on OCMock, a 3rd party framework included in this project.

The app require CoreMotion.framework, by Apple
