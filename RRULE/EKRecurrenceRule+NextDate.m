//
//  EKRecurrenceRule+NextDate.m
//  RRULE
//
//  Created by Ruslan Hristov on 9/10/14.
//  Copyright (c) 2014 Jochen Schöllig. All rights reserved.
//

#import "EKRecurrenceRule+NextDate.h"

@implementation EKRecurrenceRule (NextDate)

- (NSDate *)nextDate:(NSDate *)date
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *nextDateComponents = [[NSDateComponents alloc] init];

	NSDateComponents *currentDateComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:date];

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
		NSInteger diff = dayOfWeek.dayOfTheWeek - currentDateComponents.weekday;
		if (diff > 0)
		{
			thisInterval = true;
			nextDayOfWeek = dayOfWeek;
			break;
		}
	}
	if (!nextDayOfWeek && daysOfWeek.count)
		nextDayOfWeek = (EKRecurrenceDayOfWeek *)daysOfWeek[0];

	if (nextDayOfWeek)
		[nextDateComponents setDay:nextDayOfWeek.dayOfTheWeek - currentDateComponents.weekday]; // ?? for all ??

	switch (self.frequency)
	{
		case EKRecurrenceFrequencyDaily:
			if (!thisInterval)
				[nextDateComponents setDay:self.interval];
			break;
		case EKRecurrenceFrequencyWeekly:
		{
			if (!thisInterval)
				[nextDateComponents setWeek:self.interval];
			break;
		}
		case EKRecurrenceFrequencyMonthly:
			if (!thisInterval)
				[nextDateComponents setMonth:self.interval];
			break;
		case EKRecurrenceFrequencyYearly:
			if (!thisInterval)
				[nextDateComponents setYear:self.interval];
			break;
	}
	return [gregorian dateByAddingComponents:nextDateComponents toDate:date options:0];
}

@end
