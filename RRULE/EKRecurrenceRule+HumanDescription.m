//
//  EKRecurrenceRule+HumanDescription.m
//  RRULE
//
//  Created by Ruslan Hristov on 9/21/14.
//  Copyright (c) 2014 Ruslan Hristov. All rights reserved.
//

#import "EKRecurrenceRule+HumanDescription.h"

@implementation EKRecurrenceRule (HumanDescription)

- (NSString *)namesToString:(NSArray *)names
{
	NSString *nameStr = [names componentsJoinedByString:@", "];
	NSRange lastComma = [nameStr rangeOfString:@"," options:NSBackwardsSearch];
	if(lastComma.location != NSNotFound)
		nameStr = [nameStr stringByReplacingCharactersInRange:lastComma withString: @" and"];
	return nameStr;
}

- (NSString *)humanDescription
{
	NSMutableString *desc = [[NSMutableString alloc] init];
	[desc appendString:@"Every"];

	BOOL plural = false;
	if (self.interval > 1)
	{
		if (self.interval == 2)
			[desc appendString:@" other"];
		else
		{
			plural = true;
			[desc appendFormat:@" %ld", (long)self.interval];
		}
	}

	switch (self.frequency)
	{
		case EKRecurrenceFrequencyDaily:
			[desc appendString:@" day"];
			break;
		case EKRecurrenceFrequencyWeekly:
			[desc appendString:@" week"];
			break;
		case EKRecurrenceFrequencyMonthly:
			if (self.interval != 1 || self.monthsOfTheYear.count <= 0)
				[desc appendString:@" month"];
			break;
		case EKRecurrenceFrequencyYearly:
			if (self.interval != 1 || self.monthsOfTheYear.count <= 0)
				[desc appendString:@" year"];
			break;
	}
	if (plural)
		[desc appendString:@"s"];

	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];

	if (self.monthsOfTheYear.count > 0)
	{
		NSMutableArray *months = [[NSMutableArray alloc] init];
		for (NSNumber *month in self.monthsOfTheYear)
		{
			[dateFormatter setDateFormat:@"MM"];
			NSDate *tmp = [dateFormatter dateFromString:[NSString stringWithFormat: @"%@", month]];
			[dateFormatter setDateFormat:@"MMMM"];
			NSString *monthStr = [[dateFormatter stringFromDate:tmp] capitalizedString];
			[months addObject:monthStr];
		}
		NSString *monthsStr = [self namesToString:months];
		[desc appendString:@" "];
		if (self.interval != 1 || (self.frequency != EKRecurrenceFrequencyMonthly && self.frequency != EKRecurrenceFrequencyYearly))
			[desc appendString:@"in "];
		[desc appendString:monthsStr];
	}

	if (self.daysOfTheWeek.count)
	{
		NSMutableArray *days = [[NSMutableArray alloc] init];
		NSArray *sortedDaysOfTheWeek = [self.daysOfTheWeek sortedArrayUsingComparator:^NSComparisonResult(EKRecurrenceDayOfWeek *a, EKRecurrenceDayOfWeek *b)
		{
			return a.dayOfTheWeek > b.dayOfTheWeek;
		}];
		for (EKRecurrenceDayOfWeek *dayOfWeek in sortedDaysOfTheWeek)
		{
			NSMutableString *dayStr = [[NSMutableString alloc] init];
			switch (abs((int)dayOfWeek.weekNumber))
			{
				case 0: break;
				case 1: [dayStr appendString:(dayOfWeek.weekNumber < 0 ? @"last " : @"first ")]; break;
				case 2: [dayStr appendString:@"2nd "]; break;
				case 3: [dayStr appendString:@"3rd "]; break;
				case 4: [dayStr appendString:@"4th "]; break;
				case 5: [dayStr appendString:@"5th "]; break;
				case 6: [dayStr appendString:@"6th "]; break;
				default:
					break;
			}
			if (dayOfWeek.weekNumber < -1)
				[dayStr appendString:@"last "];
			switch (dayOfWeek.dayOfTheWeek)
			{
				case 1: [dayStr appendString:@"Sunday"]; break;
				case 2: [dayStr appendString:@"Monday"]; break;
				case 3: [dayStr appendString:@"Tuesday"]; break;
				case 4: [dayStr appendString:@"Wednesday"]; break;
				case 5: [dayStr appendString:@"Thursday"]; break;
				case 6: [dayStr appendString:@"Friday"]; break;
				case 7: [dayStr appendString:@"Saturday"]; break;
				default: [dayStr appendString:@"Unknown"]; break;
			}
			[days addObject:dayStr];
		}
		NSString *daysStr = [self namesToString:days];
		[desc appendString:@" on "];
		if ([[sortedDaysOfTheWeek firstObject] weekNumber] != 0)
			[desc appendString:@"the "];
		[desc appendString:daysStr];
	}

	return desc;
}

@end
