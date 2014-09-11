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
	return [nextDate compare:tuple.second] == NSOrderedSame;
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

- (void)testNextDateWeekly
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


}


@end
