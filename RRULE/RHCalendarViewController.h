//
//  RHCalendarViewController.h
//  RRULE
//
//  Created by Ruslan Hristov on 9/29/14.
//  Copyright (c) 2014 Ruslan Hristov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface RHCalendarViewController : UIViewController

@property (nonatomic, strong) EKRecurrenceRule *recurrenceRule;
@property (nonatomic, strong) NSDate *date;

//- (id)initWithCalendar:(NSCalendar *)calendar;

@end
