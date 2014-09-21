//
//  RRULE_Tests.m
//  RRULE Tests
//
//  Created by Ruslan Hristov on 9/9/14.
//  Copyright (c) 2014 Ruslan Hristov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EKRecurrenceRule+RRULE.h"
#import "EKRecurrenceRule+NextDate.h"

@interface Tuple : NSObject
@property (strong, nonatomic) id first;
@property (strong, nonatomic) id second;
+ (id)first:(id)first second:(id)second;
- (id)initWithFirst:(id)first andSecond:(id)second;
@end
@implementation Tuple

+ (id)first:(id)first second:(id)second
{
	return [[Tuple alloc] initWithFirst:first andSecond:second];
}
- (id)initWithFirst:(id)first andSecond:(id)second
{
	self = [super init];
	if (self)
	{
		_first = first;
		_second = second;
	}
	return self;
}
@end

@interface EKRuleNextDate_Tests : XCTestCase

@property (nonatomic, strong) NSDateFormatter *df;
@property (nonatomic, strong) NSDate *startDate;

@end

@implementation EKRuleNextDate_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	_df = [[NSDateFormatter alloc] init];
	[_df setDateFormat:@"yyyy/MM/dd HH:mm:ss zzz"];
	//	[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
	//	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	_startDate = [_df dateFromString:@"2014/05/05 09:00:00 GMT"]; // keep in GMT because NSDate description is in GMT
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (BOOL)test:(NSString *)testString result:(Tuple *)tuple
{
	EKRecurrenceRule *recurrenceRule = [[EKRecurrenceRule alloc] initWithString:testString];
	NSDate *nextDate = [recurrenceRule nextDate:tuple.first];

	BOOL result = [nextDate compare:tuple.second] == NSOrderedSame;
	if (nextDate == nil)
		result = false;
	if (!result)
		NSLog(@"*** [%@: Date:%@] Result: %@ <=> Expected: %@", testString, tuple.first, nextDate, tuple.second);
	return result;
}

- (void)testNextDateSimpleIntervals
{
	// Daily:
	XCTAssert([self test:@"FREQ=DAILY" result:[Tuple first:_startDate second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=WEEKLY" result:[Tuple first:_startDate second:[_df dateFromString:@"2014/05/12 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY" result:[Tuple first:_startDate second:[_df dateFromString:@"2014/06/05 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=YEARLY" result:[Tuple first:_startDate second:[_df dateFromString:@"2015/05/05 09:00:00 GMT"]]]);

	// Every other day
	XCTAssert([self test:@"FREQ=DAILY;INTERVAL=2" result:[Tuple first:_startDate second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]);
	// Every other week
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2" result:[Tuple first:_startDate second:[_df dateFromString:@"2014/05/19 09:00:00 GMT"]]]);
	// Every 3 months
	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=3" result:[Tuple first:_startDate second:[_df dateFromString:@"2014/08/05 09:00:00 GMT"]]]);
	// Every 4 years
	XCTAssert([self test:@"FREQ=YEARLY;INTERVAL=4" result:[Tuple first:_startDate second:[_df dateFromString:@"2018/05/05 09:00:00 GMT"]]]);
}

- (void)testNextDateByDayWeekly
{
	// Weekly on Tuesday and Thursday:
	XCTAssert([self test:@"FREQ=WEEKLY;BYDAY=TU,TH" result:[Tuple first:_startDate second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);//Mon
	XCTAssert([self test:@"FREQ=WEEKLY;BYDAY=TH,TU" result:[Tuple first:_startDate second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);//Mon
	XCTAssert([self test:@"FREQ=WEEKLY;BYDAY=TU,TH" result:[Tuple first:[_df dateFromString:@"2014/05/06 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/08 09:00:00 GMT"]]]); // Tue
	XCTAssert([self test:@"FREQ=WEEKLY;BYDAY=TU,TH" result:[Tuple first:[_df dateFromString:@"2014/05/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/13 09:00:00 GMT"]]]); // Thu
	XCTAssert([self test:@"FREQ=WEEKLY;BYDAY=TU,TH" result:[Tuple first:[_df dateFromString:@"2014/05/10 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/13 09:00:00 GMT"]]]); // Sat
	XCTAssert([self test:@"FREQ=WEEKLY;BYDAY=TU,TH" result:[Tuple first:[_df dateFromString:@"2014/05/11 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/13 09:00:00 GMT"]]]); // Sun

	// Every other week on Tuesday and Thursday:
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH"
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);//Mon
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=TH,TU"
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);//Mon
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH"
				  result:[Tuple first:[_df dateFromString:@"2014/05/06 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/08 09:00:00 GMT"]]]); // Tue
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH"
				  result:[Tuple first:[_df dateFromString:@"2014/05/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/20 09:00:00 GMT"]]]); // Thu
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH"
				  result:[Tuple first:[_df dateFromString:@"2014/05/10 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/20 09:00:00 GMT"]]]); // Sat
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH"
				  result:[Tuple first:[_df dateFromString:@"2014/05/11 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/13 09:00:00 GMT"]]]); // Sun (week starts on Sunday!)

	// Every other week on Monday, Wednesday and Friday:
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]); // Mon
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/06 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]); // Tue
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/07 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/09 09:00:00 GMT"]]]); // Wed
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/09 09:00:00 GMT"]]]); // Thu
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/09 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/19 09:00:00 GMT"]]]); // Fri
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/10 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/19 09:00:00 GMT"]]]); // Sat
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/11 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/12 09:00:00 GMT"]]]); // Sun

}

- (void)testNextDateByDayMonthly
{
	// Monthly on the 1st Friday:
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/01 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/02 09:00:00 GMT"]]]); // before 1st Friday
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/02 09:00:00 GMT"] second:[_df dateFromString:@"2014/06/06 09:00:00 GMT"]]]); // 1st Friday
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/06/06 09:00:00 GMT"]]]); // after 1st Friday
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/15 09:00:00 GMT"] second:[_df dateFromString:@"2014/06/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR"
				  result:[Tuple first:[_df dateFromString:@"2014/06/03 09:00:00 GMT"] second:[_df dateFromString:@"2014/06/06 09:00:00 GMT"]]]); // before 1st Friday
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR"
				  result:[Tuple first:[_df dateFromString:@"2014/06/06 09:00:00 GMT"] second:[_df dateFromString:@"2014/07/04 09:00:00 GMT"]]]);

	// On the 1st Friday of every other month
	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=2;BYDAY=1FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/01 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/02 09:00:00 GMT"]]]); // before 1st Friday
	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=2;BYDAY=1FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/02 09:00:00 GMT"] second:[_df dateFromString:@"2014/07/04 09:00:00 GMT"]]]); // 1st Friday -> 2nd month
	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=2;BYDAY=1FR"
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/07/04 09:00:00 GMT"]]]); // after 1st Friday

	// Monthly on the 1st Monday and Friday:
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/05/01 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/02 09:00:00 GMT"]]]); // before 1st Friday
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/05/02 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/05 09:00:00 GMT"]]]); // 1st Friday
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/05/03 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/05 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/06/01 09:00:00 GMT"] second:[_df dateFromString:@"2014/06/02 09:00:00 GMT"]]]); // before 1st Monday
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/06/02 09:00:00 GMT"] second:[_df dateFromString:@"2014/06/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/06/03 09:00:00 GMT"] second:[_df dateFromString:@"2014/06/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/06/06 09:00:00 GMT"] second:[_df dateFromString:@"2014/07/04 09:00:00 GMT"]]]);

	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/07/03 09:00:00 GMT"] second:[_df dateFromString:@"2014/07/04 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/07/04 09:00:00 GMT"] second:[_df dateFromString:@"2014/07/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/07/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/07/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/07/06 09:00:00 GMT"] second:[_df dateFromString:@"2014/07/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/07/07 09:00:00 GMT"] second:[_df dateFromString:@"2014/08/01 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=1FR,1MO"
				  result:[Tuple first:[_df dateFromString:@"2014/07/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/08/01 09:00:00 GMT"]]]);

	// Monthly on the 2nd Monday and Friday:
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=2FR,2MO"
				  result:[Tuple first:[_df dateFromString:@"2014/05/01 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/09 09:00:00 GMT"]]]); // before 2nd Friday
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=2FR,2MO"
				  result:[Tuple first:[_df dateFromString:@"2014/05/02 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/09 09:00:00 GMT"]]]); // before 2nd Friday
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=2FR,2MO"
				  result:[Tuple first:[_df dateFromString:@"2014/05/03 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/09 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=2FR,2MO"
				  result:[Tuple first:[_df dateFromString:@"2014/05/09 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/12 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=2FR,2MO"
				  result:[Tuple first:[_df dateFromString:@"2014/05/12 09:00:00 GMT"] second:[_df dateFromString:@"2014/06/09 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;BYDAY=2FR,2MO"
				  result:[Tuple first:[_df dateFromString:@"2014/06/09 09:00:00 GMT"] second:[_df dateFromString:@"2014/06/13 09:00:00 GMT"]]]);
}

- (void)testByMonthDaily
{
	XCTAssert([self test:@"FREQ=DAILY;BYMONTH=5" // May
				  result:[Tuple first:[_df dateFromString:@"2014/04/30 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/01 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=DAILY;BYMONTH=5" // May
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=DAILY;BYMONTH=5" // May
				  result:[Tuple first:[_df dateFromString:@"2014/05/15 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/16 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=DAILY;BYMONTH=5" // May
				  result:[Tuple first:[_df dateFromString:@"2014/05/30 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/31 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=DAILY;BYMONTH=5" // May
				  result:[Tuple first:[_df dateFromString:@"2014/05/31 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/01 09:00:00 GMT"]]]);

	XCTAssert([self test:@"FREQ=DAILY;INTERVAL=4;BYMONTH=5" // May
				  result:[Tuple first:[_df dateFromString:@"2014/04/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/03 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=DAILY;INTERVAL=4;BYMONTH=5" // May
				  result:[Tuple first:[_df dateFromString:@"2014/05/01 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/05 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=DAILY;INTERVAL=4;BYMONTH=5" // May
				  result:[Tuple first:[_df dateFromString:@"2014/05/03 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=DAILY;INTERVAL=4;BYMONTH=5" // May
				  result:[Tuple first:[_df dateFromString:@"2014/05/29 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/04 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=DAILY;INTERVAL=4;BYMONTH=5" // May
				  result:[Tuple first:[_df dateFromString:@"2014/05/30 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/01 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=DAILY;INTERVAL=4;BYMONTH=5" // May
				  result:[Tuple first:[_df dateFromString:@"2014/05/31 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/02 09:00:00 GMT"]]]);
}
- (void)testByMonthWeekly
{
	// FREQ=WEEKLY;DTSTART=20140305T080000Z;COUNT=60;BYMONTH=1,5
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=1;BYMONTH=1,5"
				  result:[Tuple first:[_df dateFromString:@"2014/03/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=1;BYMONTH=1,5"
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/12 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=1;BYMONTH=1,5"
				  result:[Tuple first:[_df dateFromString:@"2014/05/26 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/05 09:00:00 GMT"]]]);

	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYMONTH=1,5"
				  result:[Tuple first:[_df dateFromString:@"2014/01/23 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/01 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=WEEKLY;INTERVAL=2;BYMONTH=1,5"
				  result:[Tuple first:[_df dateFromString:@"2014/05/01 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/15 09:00:00 GMT"]]]);
}
- (void)testByMonthMonthly
{
	// MONTHLY
	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=1;BYMONTH=1,5"
				  result:[Tuple first:[_df dateFromString:@"2014/03/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/05 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=1;BYMONTH=1,5"
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/05 09:00:00 GMT"]]]);

	// MONTHLY freq with BYMONTH and INTERVAL > 1 doesn't really make sense;
	// this is also the behavior at http://jakubroztocil.github.io/rrule 
//	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=2;BYMONTH=1,5"
//				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/05 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=2;BYMONTH=1,5"
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/05 09:00:00 GMT"]]]);
//	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=3;BYMONTH=1,5"
//				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2016/01/05 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=MONTHLY;INTERVAL=3;BYMONTH=1,5"
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/05 09:00:00 GMT"]]]);
}

- (void)testByMonthYearly
{
	// YEARLY
	XCTAssert([self test:@"FREQ=YEARLY;BYMONTH=1,5" // Jan, May
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/05 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=YEARLY;BYMONTH=1,5" // Jan, May
				  result:[Tuple first:[_df dateFromString:@"2014/06/05 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/05 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=YEARLY;BYMONTH=1,5" // Jan, May
				  result:[Tuple first:[_df dateFromString:@"2014/02/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/05 09:00:00 GMT"]]]);
	XCTAssert([self test:@"FREQ=YEARLY;BYMONTH=1,5" // Jan, May
				  result:[Tuple first:[_df dateFromString:@"2014/01/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/05 09:00:00 GMT"]]]);
}

- (void)testByMonthByDayDaily
{
	XCTAssert([self test:@"BYMONTH=5;BYDAY=TU;FREQ=DAILY" // -> every Tuesday in May
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=TU;FREQ=DAILY" // -> every Tuesday in May
				  result:[Tuple first:[_df dateFromString:@"2014/05/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/13 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=TU;FREQ=DAILY" // -> every Tuesday in May
				  result:[Tuple first:[_df dateFromString:@"2014/05/13 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/20 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=TU;FREQ=DAILY" // -> every Tuesday in May
				  result:[Tuple first:[_df dateFromString:@"2014/05/27 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/05 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=TU;FREQ=DAILY" // -> every Tuesday in May
				  result:[Tuple first:[_df dateFromString:@"2014/05/28 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/05 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=TU;FREQ=DAILY" // -> every Tuesday in May
				  result:[Tuple first:[_df dateFromString:@"2014/07/02 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/05 09:00:00 GMT"]]]);

}

- (void)testByMonthByDayWeekly
{
	// BYMONTH=5;BYDAY=TU;FREQ=WEEKLY -> every Tuesday in May
	XCTAssert([self test:@"BYMONTH=5;BYDAY=TU;FREQ=WEEKLY" // -> every Tuesday in May
				  result:[Tuple first:[_df dateFromString:@"2014/03/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=TU;FREQ=WEEKLY" // -> every Tuesday in May
				  result:[Tuple first:[_df dateFromString:@"2014/05/06 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/13 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=TU;FREQ=WEEKLY" // -> every Tuesday in May
				  result:[Tuple first:[_df dateFromString:@"2014/05/27 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/05 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=TU;FREQ=WEEKLY" // -> every Tuesday in May
				  result:[Tuple first:[_df dateFromString:@"2014/06/27 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/05 09:00:00 GMT"]]]);

	// BYMONTH=1,5;BYDAY=TU,WE;FREQ=WEEKLY -> every Tue and Wed in Jan and May
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=WEEKLY" // -> every Tue and Wed in Jan and May
				  result:[Tuple first:[_df dateFromString:@"2014/03/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=WEEKLY" // -> every Tue and Wed in Jan and May
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=WEEKLY" // -> every Tue and Wed in Jan and May
				  result:[Tuple first:[_df dateFromString:@"2014/05/06 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=WEEKLY" // -> every Tue and Wed in Jan and May
				  result:[Tuple first:[_df dateFromString:@"2014/05/21 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/27 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=WEEKLY" // -> every Tue and Wed in Jan and May
				  result:[Tuple first:[_df dateFromString:@"2014/05/27 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/28 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=WEEKLY" // -> every Tue and Wed in Jan and May
				  result:[Tuple first:[_df dateFromString:@"2014/05/28 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=WEEKLY" // -> every Tue and Wed in Jan and May
				  result:[Tuple first:[_df dateFromString:@"2014/05/29 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=WEEKLY" // -> every Tue and Wed in Jan and May
				  result:[Tuple first:[_df dateFromString:@"2014/08/15 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/06 09:00:00 GMT"]]]);
}

- (void)testByMonthByDayMonthly
{
	// BYMONTH=5;BYDAY=WE;FREQ=MONTHLY -> once a month in May on Wednesday
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=MONTHLY" // -> once a month in May on Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/03/15 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=MONTHLY" // -> once a month in May on Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/01 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=MONTHLY" // -> once a month in May on Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/06 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=MONTHLY" // -> once a month in May on Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/07 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=MONTHLY" // -> once a month in May on Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=MONTHLY" // -> once a month in May on Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/27 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/28 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=MONTHLY" // -> once a month in May on Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/28 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=MONTHLY" // -> once a month in May on Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/29 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/06 09:00:00 GMT"]]]);

	// BYMONTH=5;BYDAY=WE;FREQ=YEARLY -> once a year in May on Wednesday ==> same sequence as above
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=YEARLY" // -> once a year in May on Wednesday ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/03/15 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=YEARLY" // -> once a year in May on Wednesday ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/01 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=YEARLY" // -> once a year in May on Wednesday ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/06 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=YEARLY" // -> once a year in May on Wednesday ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/07 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=YEARLY" // -> once a year in May on Wednesday ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=YEARLY" // -> once a year in May on Wednesday ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/27 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/28 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=YEARLY" // -> once a year in May on Wednesday ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/28 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=WE;FREQ=YEARLY" // -> once a year in May on Wednesday ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/29 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/06 09:00:00 GMT"]]]);

	// BYMONTH=1,5;BYDAY=TU,WE;FREQ=MONTHLY -> once a month in Jan and May on Tuesday and Wednesday
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=MONTHLY" // -> once a month in Jan and May on Tuesday and Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/03/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=MONTHLY" // -> once a month in Jan and May on Tuesday and Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=MONTHLY" // -> once a month in Jan and May on Tuesday and Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/06 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=MONTHLY" // -> once a month in Jan and May on Tuesday and Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/21 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/27 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=MONTHLY" // -> once a month in Jan and May on Tuesday and Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/27 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/28 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=MONTHLY" // -> once a month in Jan and May on Tuesday and Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/28 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=MONTHLY" // -> once a month in Jan and May on Tuesday and Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/05/29 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=MONTHLY" // -> once a month in Jan and May on Tuesday and Wednesday
				  result:[Tuple first:[_df dateFromString:@"2014/08/15 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/06 09:00:00 GMT"]]]);

	// BYMONTH=1,5;BYDAY=TU,WE;FREQ=YEARLY -> once a year in Jan and May on Tue and Wed ==> same sequence as above
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=YEARLY" // -> once a year in Jan and May on Tue and Wed ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/03/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=YEARLY" // -> once a year in Jan and May on Tue and Wed ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/05 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=YEARLY" // -> once a year in Jan and May on Tue and Wed ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/06 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/07 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=YEARLY" // -> once a year in Jan and May on Tue and Wed ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/21 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/27 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=YEARLY" // -> once a year in Jan and May on Tue and Wed ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/27 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/28 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=YEARLY" // -> once a year in Jan and May on Tue and Wed ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/28 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=YEARLY" // -> once a year in Jan and May on Tue and Wed ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/29 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/06 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=TU,WE;FREQ=YEARLY" // -> once a year in Jan and May on Tue and Wed ==> same sequence as above
				  result:[Tuple first:[_df dateFromString:@"2014/08/15 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/06 09:00:00 GMT"]]]);
}

- (void)testByMonthByDayLastWeekOfMonth
{
	// BYMONTH=5;BYDAY=-1WE;FREQ=YEARLY
	XCTAssert([self test:@"BYMONTH=5;BYDAY=-1WE;FREQ=YEARLY"
				  result:[Tuple first:[_df dateFromString:@"2014/03/15 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/28 09:00:00 GMT"]]]);
//	XCTAssert([self test:@"BYMONTH=5;BYDAY=-1WE;FREQ=YEARLY"
//				  result:[Tuple first:[_df dateFromString:@"2014/05/07 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/28 09:00:00 GMT"]]]);
}

- (void)testByMonthByDayYearly
{
	// BYMONTH=5;BYDAY=2WE;FREQ=MONTHLY -> every May on the 2nd Wed
	// BYMONTH=5;BYDAY=2WE;FREQ=YEARLY -> save as above
	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=MONTHLY" // -> every May on the 2nd Wed
				  result:[Tuple first:[_df dateFromString:@"2014/03/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=MONTHLY" // -> every May on the 2nd Wed
				  result:[Tuple first:[_df dateFromString:@"2014/05/01 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=MONTHLY" // -> every May on the 2nd Wed
				  result:[Tuple first:[_df dateFromString:@"2014/05/07 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=MONTHLY" // -> every May on the 2nd Wed
				  result:[Tuple first:[_df dateFromString:@"2014/05/13 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);

	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=MONTHLY" // -> every May on the 2nd Wed
				  result:[Tuple first:[_df dateFromString:@"2014/05/14 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/13 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=MONTHLY" // -> every May on the 2nd Wed
				  result:[Tuple first:[_df dateFromString:@"2014/05/15 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/13 09:00:00 GMT"]]]);
	// same as above
	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=YEARLY" // -> save as above
				  result:[Tuple first:[_df dateFromString:@"2014/03/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=YEARLY" // -> save as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/01 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=YEARLY" // -> save as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/07 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=YEARLY" // -> save as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/13 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);

	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=YEARLY" // -> save as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/14 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/13 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=5;BYDAY=2WE;FREQ=YEARLY" // -> save as above
				  result:[Tuple first:[_df dateFromString:@"2014/05/15 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/13 09:00:00 GMT"]]]);

	// BYMONTH=1,5;BYDAY=2WE,3TH;FREQ=MONTHLY -> every May on the 2nd Wed
	// BYMONTH=1,5;BYDAY=2WE,3TH;FREQ=YEARLY -> same as above
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=2WE,3TH;FREQ=MONTHLY" // -> every May on the 2nd Wed
				  result:[Tuple first:[_df dateFromString:@"2014/03/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=2WE,3TH;FREQ=MONTHLY" // -> every May on the 2nd Wed
				  result:[Tuple first:[_df dateFromString:@"2014/05/08 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=2WE,3TH;FREQ=MONTHLY" // -> every May on the 2nd Wed
				  result:[Tuple first:[_df dateFromString:@"2014/05/14 09:00:00 GMT"] second:[_df dateFromString:@"2014/05/15 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=2WE,3TH;FREQ=MONTHLY" // -> every May on the 2nd Wed
				  result:[Tuple first:[_df dateFromString:@"2014/05/15 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=2WE,3TH;FREQ=MONTHLY" // -> every May on the 2nd Wed
				  result:[Tuple first:[_df dateFromString:@"2014/05/16 09:00:00 GMT"] second:[_df dateFromString:@"2015/01/14 09:00:00 GMT"]]]);
	XCTAssert([self test:@"BYMONTH=1,5;BYDAY=2WE,3TH;FREQ=MONTHLY" // -> every May on the 2nd Wed
				  result:[Tuple first:[_df dateFromString:@"2015/05/13 09:00:00 GMT"] second:[_df dateFromString:@"2015/05/21 09:00:00 GMT"]]]);
}

- (void)testDebugTest
{

}

@end
