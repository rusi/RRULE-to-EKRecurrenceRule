//
//  EKRuleHumanDescription_Tests.m
//  RRULE
//
//  Created by Ruslan Hristov on 9/21/14.
//  Copyright (c) 2014 Ruslan Hristov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "EKRecurrenceRule+RRULE.h"
#import "EKRecurrenceRule+HumanDescription.h"

@interface EKRuleHumanDescription_Tests : XCTestCase

@end

@implementation EKRuleHumanDescription_Tests

- (BOOL)test:(NSString *)testString result:(NSString *)expectedResult
{
	EKRecurrenceRule *recurrenceRule = [[EKRecurrenceRule alloc] initWithString:testString];
	NSString *humanDescription = [recurrenceRule humanDescription];

	BOOL result = ([humanDescription compare:expectedResult] == NSOrderedSame);
	if (humanDescription == nil)
		result = false;
	if (!result)
		NSLog(@"*** [%@] Result: %@ <=> Expected: %@", testString, humanDescription, expectedResult);
	return result;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBasicFreq
{
	XCTAssert([self test:@"FREQ=DAILY" result:@"Every day"]);
	XCTAssert([self test:@"FREQ=WEEKLY" result:@"Every week"]);
	XCTAssert([self test:@"FREQ=MONTHLY" result:@"Every month"]);
	XCTAssert([self test:@"FREQ=YEARLY" result:@"Every year"]);

	XCTAssert([self test:@"FREQ=DAILY;INTERVAL=2" result:@"Every other day"]);
	XCTAssert([self test:@"FREQ=DAILY;INTERVAL=3" result:@"Every 3 days"]);
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2" result:@"Every other week"]);
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=4" result:@"Every 4 weeks"]);
	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=3" result:@"Every 3 months"]);
	XCTAssert([self test:@"FREQ=YEARLY;INTERVAL=4" result:@"Every 4 years"]);
}

- (void)testByDayWeekly
{
	XCTAssert([self test:@"FREQ=WEEKLY;BYDAY=MO,TU" result:@"Every week on Monday and Tuesday"]);
	XCTAssert([self test:@"FREQ=WEEKLY;BYDAY=WE,TH" result:@"Every week on Wednesday and Thursday"]);
	XCTAssert([self test:@"FREQ=WEEKLY;BYDAY=FR,SA" result:@"Every week on Friday and Saturday"]);
	XCTAssert([self test:@"FREQ=WEEKLY;BYDAY=SU" result:@"Every week on Sunday"]);
	XCTAssert([self test:@"FREQ=WEEKLY;BYDAY=TU,TH" result:@"Every week on Tuesday and Thursday"]);
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH" result:@"Every other week on Tuesday and Thursday"]);
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR" result:@"Every other week on Monday, Wednesday and Friday"]);
}

- (void)testByDayMonthly
{
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=-5FR,3MO,-1WE,1TU,1WE" result:@"Every month on the 3rd Monday, first Tuesday, last Wednesday, first Wednesday and 5th last Friday"]);

}

- (void)testByMonthDaily
{
//	XCTAssert([self test:@"" result:@"Every "]);
	XCTAssert([self test:@"FREQ=DAILY;BYMONTH=5" result:@"Every day in May"]);
	XCTAssert([self test:@"FREQ=DAILY;INTERVAL=4;BYMONTH=5" result:@"Every 4 days in May"]);
	XCTAssert([self test:@"FREQ=DAILY;INTERVAL=4;BYMONTH=5,1,3" result:@"Every 4 days in May, January and March"]);
}

- (void)testByMonthWeekly
{
	XCTAssert([self test:@"FREQ=WEEKLY;BYMONTH=1,5" result:@"Every week in January and May"]);
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYMONTH=1,5" result:@"Every other week in January and May"]);
}
- (void)testByMonthMonthly
{
	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=1;BYMONTH=1,5" result:@"Every January and May"]);
	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=2;BYMONTH=1,5" result:@"Every other month in January and May"]);
	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=3;BYMONTH=1,3,5" result:@"Every 3 months in January, March and May"]);
}

- (void)testByMonthYearly
{
	XCTAssert([self test:@"FREQ=YEARLY;BYMONTH=1,5" result:@"Every January and May"]);
	XCTAssert([self test:@"FREQ=YEARLY;INTERVAL=2;BYMONTH=1,5" result:@"Every other year in January and May"]);
	XCTAssert([self test:@"FREQ=YEARLY;INTERVAL=3;BYMONTH=1,3,5" result:@"Every 3 years in January, March and May"]);
}

- (void)testByMonthByDayDaily
{
	XCTAssert([self test:@"BYMONTH=5;BYDAY=TU;FREQ=DAILY" result:@"Every day in May on Tuesday"]);
	XCTAssert([self test:@"BYMONTH=5;INTERVAL=2;BYDAY=TU;FREQ=DAILY" result:@"Every other day in May on Tuesday"]);
	XCTAssert([self test:@"BYMONTH=5;INTERVAL=3;BYDAY=TU;FREQ=DAILY" result:@"Every 3 days in May on Tuesday"]);
}

- (void)testByMonthByDayWeekly
{
	XCTAssert([self test:@"BYMONTH=5;BYDAY=TU;FREQ=WEEKLY" result:@"Every week in May on Tuesday"]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=WEEKLY" result:@"Every week in January and May on Tuesday and Wednesday"]);
	XCTAssert([self test:@"BYMONTH=1,3,5;BYDAY=MO,TU,WE;FREQ=WEEKLY" result:@"Every week in January, March and May on Monday, Tuesday and Wednesday"]);
}

- (void)testByMonthByDayMonthly
{
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=MONTHLY" result:@"Every May on Wednesday"]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=MONTHLY;INTERVAL=4" result:@"Every 4 months in May on Wednesday"]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=YEARLY" result:@"Every May on Wednesday"]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=YEARLY;INTERVAL=3" result:@"Every 3 years in May on Wednesday"]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=MONTHLY" result:@"Every January and May on Tuesday and Wednesday"]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=YEARLY" result:@"Every January and May on Tuesday and Wednesday"]);
}

- (void)testByMonthByDayLastWeekOfMonth
{
	XCTAssert([self test:@"BYMONTH=5;BYDAY=-1WE;FREQ=YEARLY" result:@"Every May on the last Wednesday"]);
}

- (void)testByMonthByDayYearly
{
	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=MONTHLY" result:@"Every May on the 2nd Wednesday"]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=YEARLY" result:@"Every May on the 2nd Wednesday"]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=2WE,3TH;FREQ=MONTHLY" result:@"Every January and May on the 2nd Wednesday and 3rd Thursday"]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=2WE,3TH;FREQ=YEARLY" result:@"Every January and May on the 2nd Wednesday and 3rd Thursday"]);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
