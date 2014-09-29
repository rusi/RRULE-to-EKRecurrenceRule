//
//  RHReccurenceRuleViewController.h
//  RRULE
//
//  Created by Ruslan Hristov on 9/27/14.
//  Copyright (c) 2014 Ruslan Hristov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@protocol RHRecurrenceRuleViewControllerDelegate <NSObject>
- (void)recurrenceRuleCreated:(EKRecurrenceRule *)rule;
@end

@interface RHReccurenceRuleViewController : UIViewController

@property (nonatomic, weak) id<RHRecurrenceRuleViewControllerDelegate> delegate;

- (void)setEditRule:(EKRecurrenceRule *)editRule;

@end
