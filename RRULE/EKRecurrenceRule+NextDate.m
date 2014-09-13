//
//  EKRecurrenceRule+NextDate.m
//  RRULE
//
//  Created by Ruslan Hristov on 9/10/14.
//  Copyright (c) 2014 Ruslan Hristov. All rights reserved.
//


//
//+----------+-------+------+-------+------+
//|          |DAILY  |WEEKLY|MONTHLY|YEARLY|
//+----------+-------+------+-------+------+
//|BYMONTH   |Limit  |Limit |Limit  |Expand|
//+----------+-------+------+-------+------+
//|BYWEEKNO  |N/A    |N/A   |N/A    |Expand|
//+----------+-------+------+-------+------+
//|BYYEARDAY |N/A    |N/A   |N/A    |Expand|
//+----------+-------+------+-------+------+
//|BYMONTHDAY|Limit  |N/A   |Expand |Expand|
//+----------+-------+------+-------+------+
//|BYDAY     |Limit  |Expand|Note 1 |Note 2|
//+----------+-------+------+-------+------+
//|BYHOUR    |Expand |Expand|Expand |Expand|
//+----------+-------+------+-------+------+
//|BYMINUTE  |Expand |Expand|Expand |Expand|
//+----------+-------+------+-------+------+
//|BYSECOND  |Expand |Expand|Expand |Expand|
//+----------+-------+------+-------+------+
//|BYSETPOS  |Limit  |Limit |Limit  |Limit |
//+----------+-------+------+-------+------+
//
//Note 1:  Limit if BYMONTHDAY is present; otherwise, special expand
//for MONTHLY.
//
//Note 2:  Limit if BYYEARDAY or BYMONTHDAY is present; otherwise,
//special expand for WEEKLY if BYWEEKNO present; otherwise,
//special expand for MONTHLY if BYMONTH present; otherwise,
//special expand for YEARLY.

// After evaluating the specified FREQ and INTERVAL rule parts, the BYxxx rule parts
// are applied to the current set of evaluated occurrences in the following order:
// BYMONTH, BYWEEKNO, BYYEARDAY, BYMONTHDAY, BYDAY, BYHOUR, BYMINUTE, BYSECOND and BYSETPOS;
// then COUNT and UNTIL are evaluated.

#import "EKRecurrenceRule+NextDate.h"

@implementation EKRecurrenceRule (NextDate)


- (void)addInterval:(NSInteger)interval toComponent:(NSDateComponents *)nextDateComponents
{
	switch (self.frequency)
	{
		case EKRecurrenceFrequencyDaily:
			[nextDateComponents setDay:interval];
			break;
		case EKRecurrenceFrequencyWeekly:
			[nextDateComponents setWeek:interval];
			break;
		case EKRecurrenceFrequencyMonthly:
			[nextDateComponents setMonth:interval];
			break;
		case EKRecurrenceFrequencyYearly:
			[nextDateComponents setYear:interval];
			break;
	}
}

- (NSDate *)nextDate:(NSDate *)date
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *nextDateComponents = [[NSDateComponents alloc] init];

	NSDateComponents *currentDateComponents = [gregorian components:NSUIntegerMax fromDate:date];

	NSMutableArray *daysOfWeek = [NSMutableArray arrayWithArray:self.daysOfTheWeek];
	[daysOfWeek sortUsingComparator:^NSComparisonResult(EKRecurrenceDayOfWeek *day1, EKRecurrenceDayOfWeek *day2) {
		if (day1.dayOfTheWeek == day2.dayOfTheWeek)
			return day1.weekNumber > day2.weekNumber;
		return day1.dayOfTheWeek > day2.dayOfTheWeek;
	}];

	BOOL thisInterval = false;
	EKRecurrenceDayOfWeek *nextDayOfWeek = nil;
	for (EKRecurrenceDayOfWeek *dayOfWeek in daysOfWeek)
	{
		NSInteger dayDiff = dayOfWeek.dayOfTheWeek - currentDateComponents.weekday;
		NSInteger weekDiff = dayOfWeek.weekNumber - currentDateComponents.weekdayOrdinal;

		NSLog(@"-- %d, %@", currentDateComponents.weekdayOrdinal, currentDateComponents);
		NSLog(@"-- %d, %d", dayDiff, weekDiff);

		if (dayDiff > 0 && (dayOfWeek.weekNumber == 0 || weekDiff >= 0))
		{
			thisInterval = true;
			nextDayOfWeek = dayOfWeek;
			break;
		}
	}
	if (!nextDayOfWeek && daysOfWeek.count)
		nextDayOfWeek = (EKRecurrenceDayOfWeek *)daysOfWeek[0];

	NSLog(@"-- NextDayOfWeek: %d, %d, %@", nextDayOfWeek.weekNumber, nextDayOfWeek.dayOfTheWeek, nextDayOfWeek);
	if (nextDayOfWeek)
		[nextDateComponents setDay:nextDayOfWeek.dayOfTheWeek - currentDateComponents.weekday]; // ?? for all ??

	if (!thisInterval)
		[self addInterval:self.interval toComponent: nextDateComponents];

	NSDate *nextDate = [gregorian dateByAddingComponents:nextDateComponents toDate:date options:0];

	if (nextDayOfWeek.weekNumber != 0)
	{
		nextDateComponents = [[NSDateComponents alloc] init];
		if (thisInterval && nextDayOfWeek.dayOfTheWeek - currentDateComponents.weekday == 0 && nextDayOfWeek.weekNumber - currentDateComponents.weekdayOrdinal  == 0)
		{
			[self addInterval:1 toComponent:nextDateComponents];
		}

		NSDateComponents *comp = [gregorian components:NSUIntegerMax fromDate:
								  [gregorian dateByAddingComponents:nextDateComponents toDate:nextDate options:0]];
		nextDateComponents = [[NSDateComponents alloc] init];
		[nextDateComponents setWeekday:nextDayOfWeek.dayOfTheWeek];
		[nextDateComponents setWeekdayOrdinal:nextDayOfWeek.weekNumber];
		[nextDateComponents setMonth:comp.month];
		[nextDateComponents setYear:comp.year];
		[nextDateComponents setHour:comp.hour];
		[nextDateComponents setMinute:comp.minute];
		[nextDateComponents setSecond:comp.second];
//		[comp setWeekdayOrdinal:nextDayOfWeek.weekNumber];
		nextDate = [gregorian dateFromComponents:nextDateComponents];
	}
	return nextDate;
}

@end
