//
//  EKRecurrenceRule+NextDate.m
//  RRULE
//
//  Created by Ruslan Hristov on 9/10/14.
//  Copyright (c) 2014 Ruslan Hristov. All rights reserved.
//


// Table from RFC5545; contains only supported combinations:
//+----------+-------+------+-------+------+
//|          |DAILY  |WEEKLY|MONTHLY|YEARLY|
//+----------+-------+------+-------+------+
//|BYMONTH   |Limit  |Limit |Limit  |Expand|
//+----------+-------+------+-------+------+
//|BYYEARDAY |N/A    |N/A   |N/A    |Expand|
//+----------+-------+------+-------+------+
//|BYMONTHDAY|Limit  |N/A   |Expand |Expand|
//+----------+-------+------+-------+------+
//|BYDAY     |Limit  |Expand|Note 1 |Note 2|
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

@interface DateInfo : NSObject
//@property (nonatomic, strong) NSDate *potentialDate;
@property (nonatomic, strong) NSDateComponents *dateComponents;
@property (nonatomic, assign) BOOL fixedMonth;
@property (nonatomic, assign) BOOL fixedDayOfWeek;
@property (nonatomic, strong) NSCalendar *calendar;

- (NSComparisonResult)compare:(DateInfo *)other;
- (NSComparisonResult)compareTo:(NSDate *)date;
- (void)addInterval:(NSInteger)interval withFrequency:(EKRecurrenceFrequency)frequency;
@end
@implementation DateInfo

//- (id)initWithPotentialDate:(NSDate *)potentialDate
//{
//	self = [super init];
//	if (self)
//	{
//		_potentialDate = potentialDate;
//	}
//	return self;
//}
- (id)initWithComponents:(NSDateComponents *)dateComponents
{
	self = [super init];
	if (self)
	{
		_dateComponents = dateComponents;
	}
	return self;
}
- (NSCalendar *)calendar
{
	if (!_calendar)
	{
		_calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		[_calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	}
	return _calendar;
}
- (NSDate *)getDate
{
	return [self.calendar dateFromComponents:self.dateComponents];
}
- (NSComparisonResult)compare:(DateInfo *)other
{
	return [[self getDate] compare:[other getDate]];
}
- (NSComparisonResult)compareTo:(NSDate *)date
{
	NSDate *tmp = [self.calendar dateFromComponents:self.dateComponents];
	return [tmp compare:date];
}
- (void)addInterval:(NSInteger)interval withFrequency:(EKRecurrenceFrequency)frequency
{
	NSDate *tmp = [self.calendar dateFromComponents:self.dateComponents];
	NSDateComponents *cmp = [[NSDateComponents alloc] init];
	switch (frequency) {
		case EKRecurrenceFrequencyDaily:
			[cmp setDay:interval];
			break;
		case EKRecurrenceFrequencyWeekly:
			[cmp setWeek:interval];
			break;
		case EKRecurrenceFrequencyMonthly:
			[cmp setMonth:interval];
			break;
		case EKRecurrenceFrequencyYearly:
			[cmp setYear:interval];
			break;
	}
	tmp = [self.calendar dateByAddingComponents:cmp toDate:tmp options:0];
	cmp = [self.calendar components:NSUIntegerMax fromDate:tmp];
	if (self.fixedMonth && cmp.month != self.dateComponents.month)
	{
		NSAssert(frequency == EKRecurrenceFrequencyDaily, @"cmp.month != dateComponents.month should only be different with Daily freq.");
		[cmp setMonth:self.dateComponents.month];
		tmp = [self.calendar dateFromComponents:cmp];

		cmp = [[NSDateComponents alloc] init];
		[cmp setYear:1];
		tmp = [self.calendar dateByAddingComponents:cmp toDate:tmp options:0];
	}
	self.dateComponents = [self.calendar components:NSUIntegerMax fromDate:tmp];
//	NSLog(@"%@", self.dateComponents);
}
@end

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
	[gregorian setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	NSDateComponents *currentDateComponents = [gregorian components:NSUIntegerMax fromDate:date];

	NSMutableArray *potentialDates = [[NSMutableArray alloc] init];
	//eval BYMONTH = monthsOfTheYear
	if (self.monthsOfTheYear.count)
	{
		// DAILY, WEEKLY, MONTHLY -- limit
		// YEARLY -- expand (add recurrence for each specified month

		// according to the documentation, this is only valid for YEARLY occurence...
		for (NSNumber *month in self.monthsOfTheYear)
		{
			NSDateComponents *dc = [gregorian components:NSUIntegerMax fromDate:date];
			if (self.frequency == EKRecurrenceFrequencyDaily && dc.month != month.integerValue)
				[dc setDay:1];
			[dc setMonth:[month integerValue]];
			DateInfo *info = [[DateInfo alloc] initWithComponents:dc];
			info.fixedMonth = true;
			[potentialDates addObject:info];
		}
	}

	//eval BYYEARDAY = ??? TODO ???


	if (potentialDates.count <= 0)
		[potentialDates addObject:[[DateInfo alloc] initWithComponents:currentDateComponents]];

	[potentialDates enumerateObjectsUsingBlock:^(DateInfo *potentialDate, NSUInteger idx, BOOL *stop)
	{
		if ([potentialDate compareTo:date] <= NSOrderedSame)
			[potentialDate addInterval:self.interval withFrequency:self.frequency];
	}];
	[potentialDates sortUsingComparator:^NSComparisonResult(id a, id b)
	{
		return [a compare:b];
	}];

	return [[potentialDates firstObject] getDate];

	// ---------------------
	NSDateComponents *nextDateComponents = [[NSDateComponents alloc] init];
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
