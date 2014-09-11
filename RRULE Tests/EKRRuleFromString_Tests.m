//
//  EKRRuleFromString_Tests.m
//  RRULE
//
//  Created by Ruslan Hristov on 9/11/14.
//  Copyright (c) 2014 Jochen Schöllig. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EKRecurrenceRule+RRULE.h"

@interface EKRRuleFromString_Tests : XCTestCase

@end

@implementation EKRRuleFromString_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRFC2445StringConversions
{
	NSDictionary *rfc2445TestStrings =
	@{
	  // Daily for 10 occurrences:
	  @"FREQ=DAILY;COUNT=10" : @"FREQ=DAILY;INTERVAL=1;COUNT=10",

	  // Daily until December 24, 1997
	  @"FREQ=DAILY;UNTIL=19971224T000000Z" : @"FREQ=DAILY;INTERVAL=1;UNTIL=19971224T000000Z",

	  // Every other day - forever:
	  @"FREQ=DAILY;INTERVAL=2" : @"FREQ=DAILY;INTERVAL=2",

	  // Every 10 days, 5 occurrences:
	  @"FREQ=DAILY;INTERVAL=10;COUNT=5" : @"FREQ=DAILY;INTERVAL=10;COUNT=5",

	  // Everyday in January, for 3 years:
	  @"FREQ=YEARLY;UNTIL=20000131T090000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA" : @"FREQ=YEARLY;INTERVAL=1;UNTIL=20000131T090000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA",
	  @"FREQ=DAILY;UNTIL=20000131T090000Z;BYMONTH=1" : @"FREQ=DAILY;INTERVAL=1;UNTIL=20000131T090000Z;BYMONTH=1",

	  // Weekly for 10 occurrences:
	  @"FREQ=WEEKLY;COUNT=10" : @"FREQ=WEEKLY;INTERVAL=1;COUNT=10",

	  // Weekly until December 24, 1997:
	  @"FREQ=WEEKLY;UNTIL=19971224T000000Z" : @"FREQ=WEEKLY;INTERVAL=1;UNTIL=19971224T000000Z",

	  // Every other week - forever:
	  @"FREQ=WEEKLY;INTERVAL=2;WKST=SU" : @"FREQ=WEEKLY;INTERVAL=2",

	  // Weekly on Tuesday and Thursday for 5 weeks:
	  @"FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH" : @"FREQ=WEEKLY;INTERVAL=1;UNTIL=19971007T000000Z;BYDAY=TU,TH",
	  @"FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH" : @"FREQ=WEEKLY;INTERVAL=1;COUNT=10;BYDAY=TU,TH",

	  // Every other week on Monday, Wednesday and Friday until December 24, 1997:
	  @"FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;BYDAY=MO,WE,FR" : @"FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;BYDAY=MO,WE,FR;WKST=SU",

	  // Monthly on the 1st Friday for ten occurrences:
	  @"FREQ=MONTHLY;COUNT=10;BYDAY=1FR" : @"FREQ=MONTHLY;INTERVAL=1;COUNT=10;BYDAY=1FR",

	  // Monthly on the 1st Friday until December 24, 1997:
	  @"FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR" : @"FREQ=MONTHLY;INTERVAL=1;UNTIL=19971224T000000Z;BYDAY=1FR",

	  // Every other month on the 1st and last Sunday of the month for 10 occurrences:
	  @"FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU" : @"FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU",

	  // Monthly on the second to last Monday of the month for 6 months:
	  @"FREQ=MONTHLY;COUNT=6;BYDAY=-2MO" : @"FREQ=MONTHLY;INTERVAL=1;COUNT=6;BYDAY=-2MO",

	  // Monthly on the third to the last day of the month, forever:
	  @"FREQ=MONTHLY;BYMONTHDAY=-3" : @"FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=-3",

	  // Monthly on the 2nd and 15th of the month for 10 occurrences:
	  @"FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15" : @"FREQ=MONTHLY;INTERVAL=1;COUNT=10;BYMONTHDAY=2,15",

	  // Monthly on the first and last day of the month for 10 occurrences:
	  @"FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1" : @"FREQ=MONTHLY;INTERVAL=1;COUNT=10;BYMONTHDAY=1,-1",

	  // Every 18 months on the 10th thru 15th of the month for 10 occurrences:
	  @"FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15" : @"FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15",

	  // Every Tuesday, every other month:
	  @"FREQ=MONTHLY;INTERVAL=2;BYDAY=TU" : @"FREQ=MONTHLY;INTERVAL=2;BYDAY=TU",

	  // Yearly in June and July for 10 occurrences:
	  @"FREQ=YEARLY;COUNT=10;BYMONTH=6,7" : @"FREQ=YEARLY;INTERVAL=1;COUNT=10;BYMONTH=6,7",

	  // Every other year on January, February, and March for 10 occurrences:
	  @"FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3" : @"FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3",

	  // Every 3rd year on the 1st, 100th and 200th day for 10 occurrences:
	  @"FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200" : @"FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200",

	  // Every 20th Monday of the year, forever:
	  @"FREQ=YEARLY;BYDAY=20MO" : @"FREQ=YEARLY;INTERVAL=1;BYDAY=20MO",

	  // Monday of week number 20 (where the default start of the week is Monday), forever:
	  @"FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO" : @"FREQ=YEARLY;INTERVAL=1;BYWEEKNO=20;BYDAY=MO",

	  // Every Thursday in March, forever:
	  @"FREQ=YEARLY;BYMONTH=3;BYDAY=TH" : @"FREQ=YEARLY;INTERVAL=1;BYMONTH=3;BYDAY=TH",

	  // Every Thursday, but only during June, July, and August, forever:
	  @"FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8" : @"FREQ=YEARLY;INTERVAL=1;BYMONTH=6,7,8;BYDAY=TH",

	  // Every Friday the 13th, forever:
	  @"FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13" : @"FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=13;BYDAY=FR",

	  // The first Saturday that follows the first Sunday of the month, forever:
	  @"FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13" : @"FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=7,8,9,10,11,12,13;BYDAY=SA",

	  // Every four years, the first Tuesday after a Monday in November, forever (U.S. Presidential Election day):
	  @"FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8" : @"FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYMONTHDAY=2,3,4,5,6,7,8;BYDAY=TU",

	  // The 3rd instance into the month of one of Tuesday, Wednesday or Thursday, for the next 3 months:
	  @"FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3" : @"FREQ=MONTHLY;INTERVAL=1;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3",

	  // The 2nd to last weekday of the month:
	  @"FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2" : @"FREQ=MONTHLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2",
	  };

	[rfc2445TestStrings enumerateKeysAndObjectsUsingBlock:^(NSString *testString, NSString *resultString, BOOL *stop)
	 {
		 EKRecurrenceRule *recurrenceRule = [[EKRecurrenceRule alloc] initWithString:testString];
		 NSString *result = [[[recurrenceRule description] componentsSeparatedByString:@" "] lastObject];
		 XCTAssertEqualObjects(result, resultString, @"%@ != %@", recurrenceRule, resultString);
	 }];
}

@end
