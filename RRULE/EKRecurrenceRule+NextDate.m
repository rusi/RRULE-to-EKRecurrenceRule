//
//  EKRecurrenceRule+NextDate.m
//  RRULE
//
//  Created by Ruslan Hristov on 9/10/14.
//  Copyright (c) 2014 Ruslan Hristov. All rights reserved.
//


// Table from RFC5545; contains only supported combinations:
//+-----------+-------+------+-------+------+
//|           |DAILY  |WEEKLY|MONTHLY|YEARLY|
//+-----------+-------+------+-------+------+
//|*BYMONTH   |Limit  |Limit |Limit  |Expand|
//+-----------+-------+------+-------+------+
//| BYYEARDAY |N/A    |N/A   |N/A    |Expand|
//+-----------+-------+------+-------+------+
//| BYMONTHDAY|Limit  |N/A   |Expand |Expand|
//+-----------+-------+------+-------+------+
//|*BYDAY     |Limit  |Expand|Note 1 |Note 2|
//+-----------+-------+------+-------+------+
//| BYSETPOS  |Limit  |Limit |Limit  |Limit |
//+-----------+-------+------+-------+------+
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

@interface DateInfo : NSObject <NSCopying>
//@property (nonatomic, strong) NSDate *potentialDate;
@property (nonatomic, strong) NSDateComponents *dateComponents;
@property (nonatomic, assign) EKRecurrenceFrequency frequency;
@property (nonatomic, assign) NSInteger interval;
@property (nonatomic, assign) NSInteger fixedMonth;
@property (nonatomic, assign) EKRecurrenceDayOfWeek *fixedDayOfTheWeek;
@property (nonatomic, strong) NSCalendar *calendar;

- (id)initWithComponents:(NSDateComponents *)dateComponents frequency:(EKRecurrenceFrequency)frequency andInterval:(NSInteger)interval;
- (NSComparisonResult)compare:(DateInfo *)other;
- (NSComparisonResult)compareToDate:(NSDate *)date;
- (void)addInterval:(NSInteger)interval withFrequency:(EKRecurrenceFrequency)frequency;
@end
@implementation DateInfo


- (id)initWithComponents:(NSDateComponents *)dateComponents frequency:(EKRecurrenceFrequency)frequency andInterval:(NSInteger)interval
{
	self = [super init];
	if (self)
	{
		_dateComponents = dateComponents;
		_frequency = frequency;
		_interval = interval;

	}
	return self;
}
-(id)copyWithZone:(NSZone *)zone
{
	// We'll ignore the zone for now
	DateInfo *another = [[DateInfo alloc] init];
	another.dateComponents = [self.dateComponents copyWithZone: zone];
	another.frequency = self.frequency;
	another.interval = self.interval;
	another.fixedMonth = self.fixedMonth;
	another.fixedDayOfTheWeek = self.fixedDayOfTheWeek;
	another.calendar = [self.calendar copyWithZone: zone];

	return another;
}
-(NSString*)description
{
	return [NSString stringWithFormat:@"%@", [self getDate]];
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
- (NSComparisonResult)compareToDate:(NSDate *)date
{
	NSDate *tmp = [self.calendar dateFromComponents:self.dateComponents];
	return [tmp compare:date];
}
- (void)enforceRules
{
	// BYMONTH
	if (self.fixedMonth && self.fixedMonth != self.dateComponents.month)
	{
		if (self.frequency == EKRecurrenceFrequencyYearly)
		{
			if (self.fixedMonth < self.dateComponents.month)
				[self addInterval:1];
			[self.dateComponents setMonth:self.fixedMonth];
		}
		NSInteger interval = self.interval;
		// combining BYMONTH and INTERVAL > 1 with MONTHLY frequency doesn't really make sense...
		if (self.frequency == EKRecurrenceFrequencyMonthly)
			interval = 1;
		while (self.fixedMonth != self.dateComponents.month)
		{
			[self addInterval:interval];
		}
	}
	//BYDAY
	if (self.fixedDayOfTheWeek && self.fixedDayOfTheWeek.dayOfTheWeek != self.dateComponents.weekday)
	{
		if (self.fixedDayOfTheWeek.dayOfTheWeek < self.dateComponents.weekday)
			[self addInterval:self.interval];
		NSDateComponents *dc = [[NSDateComponents alloc] init];
		[dc setDay:self.fixedDayOfTheWeek.dayOfTheWeek - self.dateComponents.weekday];
		NSDate *tmp = [self.calendar dateByAddingComponents:dc toDate:[self getDate] options:0];
		self.dateComponents = [self.calendar components:NSUIntegerMax fromDate:tmp];
//		[self.dateComponents setWeekday:self.fixedDayOfTheWeek.dayOfTheWeek];
	}
	//			if (dayOfWeek.weekNumber)
}
- (void)nextInterval
{
	[self addInterval:self.interval];
	[self enforceRules];
}
- (void)addInterval:(NSInteger)interval
{
	NSDate *tmp = [self.calendar dateFromComponents:self.dateComponents];
	NSDateComponents *cmp = [[NSDateComponents alloc] init];
	switch (self.frequency) {
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
	self.dateComponents = [self.calendar components:NSUIntegerMax fromDate:tmp];
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
	if (self.fixedMonth && cmp.month != self.fixedMonth)
	{
		NSAssert(frequency == EKRecurrenceFrequencyDaily || frequency == EKRecurrenceFrequencyMonthly,
				 @"cmp.month != dateComponents.month should only be different with Daily or Monthly freq.");
		[cmp setMonth:self.fixedMonth];
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

- (void)addPotentialDatesTo:(NSMutableArray *)potentialDates startingWith:(DateInfo *)currentInfo// after:(NSDate *)date
{
	// if equal, then we add to potential dates; then the interval will pick the next object...
//	if ([currentInfo compareToDate:date] >= NSOrderedSame)
		[potentialDates addObject:currentInfo];

	DateInfo *lastInfo = [currentInfo copy];
	for (int i = 0; i < self.interval; ++i)
	{
		DateInfo *info = [lastInfo copy];
		[info nextInterval];
		[potentialDates addObject:info];
		lastInfo = [info copy];
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
		// YEARLY -- expand (add recurrence for each specified month)

		// according to the documentation, this is only valid for YEARLY occurence...
		for (NSNumber *month in self.monthsOfTheYear)
		{
			DateInfo *info = [[DateInfo alloc] initWithComponents:currentDateComponents frequency:self.frequency andInterval:self.interval];
			info.fixedMonth = [month integerValue];
			[info enforceRules];
			[self addPotentialDatesTo:potentialDates startingWith:info];//] after:date];
		}
	}

	//eval BYYEARDAY = ??? TODO ???

	//eval BYDAY = daysOfTheWeek
	if (self.daysOfTheWeek.count)
	{
		if (potentialDates.count)
		{
			for (EKRecurrenceDayOfWeek *dayOfWeek in self.daysOfTheWeek)
			{
				NSAssert(!dayOfWeek.weekNumber || self.frequency >= EKRecurrenceFrequencyMonthly, @"WeekNumber cannot be specified with < Monthly freq.");
				for (DateInfo *info in potentialDates)
				{
					info.fixedDayOfTheWeek = dayOfWeek;
					[info enforceRules];
				}
			}
		}
		else
		{
			for (EKRecurrenceDayOfWeek *dayOfWeek in self.daysOfTheWeek)
			{
				DateInfo *info = [[DateInfo alloc] initWithComponents:currentDateComponents frequency:self.frequency andInterval:self.interval];
				info.fixedDayOfTheWeek = dayOfWeek;
				[info enforceRules];
				[self addPotentialDatesTo:potentialDates startingWith:info];//] after:date];
			}
		}
	}

	if (potentialDates.count <= 0)
	{
		DateInfo *info = [[DateInfo alloc] initWithComponents:currentDateComponents frequency:self.frequency andInterval:self.interval];
		[self addPotentialDatesTo:potentialDates startingWith:info];// after:date];
	}
//	[potentialDates enumerateObjectsUsingBlock:^(DateInfo *potentialDate, NSUInteger idx, BOOL *stop)
//	{
//		if ([potentialDate compareTo:date] <= NSOrderedSame)
//			[potentialDate addInterval:self.interval withFrequency:self.frequency];
//	}];

	[potentialDates sortUsingComparator:^NSComparisonResult(id a, id b)
	{
		return [a compare:b];
	}];

	NSLog(@"%@", potentialDates);

	// if the first object is the same as the input date; then show the next 'interval'
////	NSInteger interval = self.interval;
//	if (self.frequency == EKRecurrenceFrequencyWeekly)
//	{
//		for (DateInfo *info in potentialDates)
//		{
//			if (info.dateComponents.weekOfYear == currentDateComponents.weekOfYear
//				&& [info compareToDate:date] != NSOrderedSame)
//			{
//				return [info getDate];
//			}
//		}
////		if (self.daysOfTheWeek.count)
////			interval *= self.daysOfTheWeek.count;
//	}
	if ([[potentialDates firstObject] compareToDate:date] == NSOrderedSame)
	{
		//NSAssert(potentialDates.count >= self.interval, @"Missing next date candidates for the specified interval");
		return [[potentialDates objectAtIndex:1 /*interval*/] getDate]; //self.interval
	}
	// otherwise, align the date to the first valid date based on the rules
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

@end
