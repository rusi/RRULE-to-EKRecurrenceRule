//
//  RHReccurenceRuleViewController.m
//  RRULE
//
//  Created by Ruslan Hristov on 9/27/14.
//  Copyright (c) 2014 Ruslan Hristov. All rights reserved.
//

#import "RHReccurenceRuleViewController.h"
#import <EventKit/EventKit.h>
#import "EKRecurrenceRule+HumanDescription.h"
#import "MultiSelectSegmentedControl.h"

@interface RHReccurenceRuleViewController () <MultiSelectSegmentedControlDelegate>

@property (weak, nonatomic) IBOutlet UILabel *intervalLabel;
@property (weak, nonatomic) IBOutlet UIStepper *intervalStepper;
@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *daysOfTheWeekSegment;
@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *monthsSegmentA;
@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *monthsSegmentB;

@property (weak, nonatomic) IBOutlet UILabel *ruleText;


//@property (strong, nonatomic) EKRecurrenceRule *rule;
@property (nonatomic, assign) EKRecurrenceFrequency freq;
@property (nonatomic, assign) NSInteger interval;
@property (nonatomic, strong) NSMutableSet *daysOfTheWeek;
@property (nonatomic, strong) NSMutableSet *monthsOfTheYear;
@end

@implementation RHReccurenceRuleViewController

- (id)init
{
	self = [super init];
	if (self)
	{
		[self setup];
	}
	return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
		[self setup];
	return self;
}

- (void)setup
{
	_freq = EKRecurrenceFrequencyDaily;
	_interval = 1;
	_daysOfTheWeek = [[NSMutableSet alloc] init];
	_monthsOfTheYear = [[NSMutableSet alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.daysOfTheWeekSegment.delegate = self;
	self.monthsSegmentA.delegate = self;
	self.monthsSegmentB.delegate = self;
	[self disableDaysOfTheWeek];
	[self updateIntervalLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (EKRecurrenceRule *)rule
//{
//	if (!_rule)
//		_rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 end:nil];
//	return _rule;
//}

- (EKRecurrenceRule *)rule
{
	return [[EKRecurrenceRule alloc]
	 initRecurrenceWithFrequency:self.freq
	 interval:self.interval
	 daysOfTheWeek:[self.daysOfTheWeek allObjects]
	 daysOfTheMonth:nil //self.rule.daysOfTheMonth
	 monthsOfTheYear:[self.monthsOfTheYear allObjects]
	 weeksOfTheYear:nil //self.rule.weeksOfTheYear
	 daysOfTheYear:nil //self.rule.daysOfTheYear
	 setPositions:nil //self.rule.setPositions
	 end:nil ]; //self.rule.recurrenceEnd];
}

- (void)updateIntervalLabel
{
	NSMutableString *text = [[NSMutableString alloc] init];
	[text appendString:@"Repeat every "];
	if (self.interval > 1)
		[text appendFormat:@"%ld ", (long)self.interval];
//	else if (self.interval == 2)
//		[text appendString:@"other "];

	switch (self.freq)
	{
		case EKRecurrenceFrequencyDaily: [text appendString:@"day"]; break;
		case EKRecurrenceFrequencyWeekly: [text appendString:@"week"]; break;
		case EKRecurrenceFrequencyMonthly: [text appendString:@"month"]; break;
		case EKRecurrenceFrequencyYearly: [text appendString:@"year"]; break;
	}
	if (self.interval > 2)
		[text appendString:@"s"];
	self.intervalLabel.text = text;

	self.ruleText.text = [[self rule] humanDescription];
}

- (void)disableDaysOfTheWeek
{
	[self.daysOfTheWeek removeAllObjects];
	[self.daysOfTheWeekSegment setSelectedSegmentIndexes:nil];
	self.daysOfTheWeekSegment.enabled = NO;
}

- (IBAction)intervalStepperChanged:(UIStepper *)sender
{
	self.interval = sender.value;
	[self updateIntervalLabel];
}

- (IBAction)frequencySelected:(UISegmentedControl *)sender
{
	switch (sender.selectedSegmentIndex)
	{
		default:
		case 0:
			self.freq = EKRecurrenceFrequencyDaily;
			[self disableDaysOfTheWeek];
			break;
		case 1:
			self.freq = EKRecurrenceFrequencyWeekly;
			self.daysOfTheWeekSegment.enabled = YES;
			break;
		case 2: self.freq = EKRecurrenceFrequencyMonthly;
			[self disableDaysOfTheWeek];
			break;
		case 3: self.freq = EKRecurrenceFrequencyYearly;
			[self disableDaysOfTheWeek];
			break;
	}
	[self updateIntervalLabel];
}

- (void)multiSelect:(MultiSelectSegmentedControl *)multiSelecSegmendedControl didChangeValue:(BOOL)value atIndex:(NSUInteger)index
{
	NSMutableSet *objSet = nil;
	id obj = nil;
	if (multiSelecSegmendedControl == self.daysOfTheWeekSegment)
	{
		objSet = self.daysOfTheWeek;
		EKRecurrenceDayOfWeek *dayOfTheWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:(index+1) weekNumber:0];
		obj = dayOfTheWeek;
	}
	if (multiSelecSegmendedControl == self.monthsSegmentA)
	{
		objSet = self.monthsOfTheYear;
		obj = [NSNumber numberWithInteger:index+1];
	}
	if (multiSelecSegmendedControl == self.monthsSegmentB)
	{
		objSet = self.monthsOfTheYear;
		obj = [NSNumber numberWithInteger:index+1+6];
	}
	if (value)
		[objSet addObject:obj];
	else
		[objSet removeObject:obj];

	[self updateIntervalLabel];
}

- (IBAction)cancel:(UIBarButtonItem *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
