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
		//[_calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
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

- (void)enforceByMonthRules
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
}

- (void)setFixedDayOfTheWeek:(EKRecurrenceDayOfWeek *)fixedDayOfTheWeek
{
	_fixedDayOfTheWeek = fixedDayOfTheWeek;

	if (self.fixedDayOfTheWeek && self.fixedDayOfTheWeek.weekNumber)
		self.frequency = EKRecurrenceFrequencyMonthly;

	if (self.fixedDayOfTheWeek && !self.fixedDayOfTheWeek.weekNumber
		&& self.fixedDayOfTheWeek.dayOfTheWeek < self.dateComponents.weekday)
	{
		[self addInterval:self.interval];
		[self enforceByMonthRules];
	}
}
- (void)enforceByDayRules
{
	//BYDAY
	if (self.fixedDayOfTheWeek &&
		(self.fixedDayOfTheWeek.dayOfTheWeek != self.dateComponents.weekday
		 || self.fixedDayOfTheWeek.weekNumber != self.dateComponents.weekdayOrdinal))
	{
		if (self.fixedDayOfTheWeek.weekNumber)
		{
			NSDateComponents *cmp = [self.dateComponents copy];
			cmp = [[NSDateComponents alloc] init];
			[cmp setWeekday:self.fixedDayOfTheWeek.dayOfTheWeek];
			[cmp setWeekdayOrdinal:self.fixedDayOfTheWeek.weekNumber];
			[cmp setMonth:self.dateComponents.month];
			[cmp setYear:self.dateComponents.year];
			[cmp setHour:self.dateComponents.hour];
			[cmp setMinute:self.dateComponents.minute];
			[cmp setSecond:self.dateComponents.second];
			self.dateComponents = cmp;
		}
		else
		{
			NSDateComponents *dc = [[NSDateComponents alloc] init];
			[dc setDay:self.fixedDayOfTheWeek.dayOfTheWeek - self.dateComponents.weekday];
			NSDate *tmp = [self.calendar dateByAddingComponents:dc toDate:[self getDate] options:0];
			self.dateComponents = [self.calendar components:NSUIntegerMax fromDate:tmp];
			[self enforceByMonthRules];
		}
	}
}

- (void)enforceRules
{
	[self enforceByMonthRules];
	[self enforceByDayRules];
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
			[cmp setWeekOfMonth:interval];
			break;
		case EKRecurrenceFrequencyMonthly:
			[cmp setMonth:interval];
			break;
		case EKRecurrenceFrequencyYearly:
			[cmp setYear:interval];
			break;
	}
	tmp = [self.calendar dateByAddingComponents:cmp toDate:tmp options:0];
	// we are going to set the day anyway, so reset the day
	if (self.fixedDayOfTheWeek.weekNumber)
	{
		NSInteger components = NSCalendarUnitEra |	NSCalendarUnitYear | NSCalendarUnitMonth | /* NSCalendarUnitDay |*/
			NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond |
			NSCalendarUnitCalendar | NSCalendarUnitTimeZone;
		cmp = [self.calendar components:components fromDate:tmp];
		[cmp setDay:1];
		tmp = [self.calendar dateFromComponents:cmp];
	}
	self.dateComponents = [self.calendar components:NSUIntegerMax fromDate:tmp];
}
@end

@implementation EKRecurrenceRule (NextDate)

- (void)addPotentialDatesTo:(NSMutableArray *)potentialDates startingWith:(DateInfo *)currentInfo// after:(NSDate *)date
{
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

- (NSArray *)getPotentialDatesFor:(NSDate *)date
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	//[gregorian setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	NSDateComponents *currentDateComponents = [gregorian components:NSUIntegerMax fromDate:date];

	NSMutableArray *seeding = [[NSMutableArray alloc] init];
	//eval BYMONTH = monthsOfTheYear
	if (self.monthsOfTheYear.count)
	{
		// DAILY, WEEKLY, MONTHLY -- limit
		// YEARLY -- expand (add recurrence for each specified month)

		// according to the documentation, this is only valid for YEARLY occurence...
		for (NSNumber *month in self.monthsOfTheYear)
		{
			EKRecurrenceFrequency freq = self.frequency;
			if (self.daysOfTheWeek.count) // special expand for Monthly when BYDAY is present
			{
				freq = EKRecurrenceFrequencyWeekly;
			}

			DateInfo *info = [[DateInfo alloc] initWithComponents:currentDateComponents frequency:freq andInterval:self.interval];
			info.fixedMonth = [month integerValue];
			[seeding addObject:info];
		}
	}

	//eval BYYEARDAY = ??? TODO ???

	//eval BYDAY = daysOfTheWeek
	if (self.daysOfTheWeek.count)
	{
		if (!seeding.count)
			[seeding addObject:[[DateInfo alloc] initWithComponents:currentDateComponents frequency:self.frequency andInterval:self.interval]];

		NSMutableArray *tmp = seeding;
		seeding = [[NSMutableArray alloc] init];

		for (DateInfo *tmpInfo in tmp)
		{
			for (EKRecurrenceDayOfWeek *dayOfWeek in self.daysOfTheWeek)
			{
				NSAssert(!dayOfWeek.weekNumber || self.frequency >= EKRecurrenceFrequencyMonthly, @"WeekNumber cannot be specified with < Monthly freq.");
				DateInfo *info = [tmpInfo copy];
				info.fixedDayOfTheWeek = dayOfWeek;
				[seeding addObject:info];
			}
		}
	}

	NSMutableArray *potentialDates = [[NSMutableArray alloc] init];
	for (DateInfo *info in seeding)
	{
		[info enforceRules];
		[self addPotentialDatesTo:potentialDates startingWith:info];//] after:date];
	}

	if (potentialDates.count <= 0)
	{
		DateInfo *info = [[DateInfo alloc] initWithComponents:currentDateComponents frequency:self.frequency andInterval:self.interval];
		[self addPotentialDatesTo:potentialDates startingWith:info];// after:date];
	}

	// sort
	[potentialDates sortUsingComparator:^NSComparisonResult(id a, id b)
	{
		return [a compare:b];
	}];

	//NSLog(@"%@", potentialDates);

	return potentialDates;
}

- (NSDate *)nextDate:(NSDate *)date
{
	NSArray *potentialDates = [self getPotentialDatesFor:date];

	// find the first date from the sequence that is > than the start date
	for (DateInfo *info in potentialDates)
	{
		if ([info compareToDate:date] > NSOrderedSame)
			return [info getDate];
	}

	NSAssert(false, @"Couldn't calculate next date.");
	return nil;
}

- (BOOL)dateMatchesRules:(NSDate *)date
{
	NSArray *potentialDates = [self getPotentialDatesFor:date];

	return [[[potentialDates firstObject] getDate] compare:date] == NSOrderedSame;
}

@end
