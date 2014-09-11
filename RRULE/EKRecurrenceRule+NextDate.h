//
//  EKRecurrenceRule+NextDate.h
//  RRULE
//
//  Created by Ruslan Hristov on 9/10/14.
//  Copyright (c) 2014 Jochen Schöllig. All rights reserved.
//

#import <EventKit/EventKit.h>

@interface EKRecurrenceRule (NextDate)

- (NSDate *)nextDate:(NSDate *)date;

@end
