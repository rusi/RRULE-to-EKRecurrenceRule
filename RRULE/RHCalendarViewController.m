//
//  RHCalendarViewController.m
//  RRULE
//
//  Created by Ruslan Hristov on 9/29/14.
//  Copyright (c) 2014 Ruslan Hristov. All rights reserved.
//

#import "RHCalendarViewController.h"
#import "RSDFDatePickerView.h"

#import "EKRecurrenceRule+NextDate.h"

@interface RHCalendarViewController () <RSDFDatePickerViewDataSource>

@property (strong, nonatomic) RSDFDatePickerView *calendarView;
//@property (strong, nonatomic) NSCalendar *calendar;

@property (nonatomic, strong) NSMutableSet *cachedDates;

@end

@implementation RHCalendarViewController

//- (id)initWithCalendar:(NSCalendar *)calendar
//{
//	self = [super init];
//	if (self)
//	{
//		_calendar = calendar;
//	}
//	return self;
//}

- (void)loadView
{
//	self.navigationController.navigationBar.translucent = NO;

	self.title = @"Calendar";

	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	calendar.locale = [NSLocale currentLocale];

	CGRect bounds = CGRectMake(0, 0, 100, 100);
	_calendarView = [[RSDFDatePickerView alloc] initWithFrame:bounds calendar:calendar];
//	_calendarView.delegate = self;
	_calendarView.dataSource = self;
	_calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	self.view = self.calendarView;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
//	if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
//		self.edgesForExtendedLayout = UIRectEdgeNone;

	// Check if we are running on ios7
	if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7)
	{
		CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
		float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;

		UICollectionView *view = (UICollectionView *)self.calendarView.collectionView;
		view.contentInset = UIEdgeInsetsMake(heightPadding, 0.0, 0.0, 0.0);
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	//self.imageView.image = [self.recipe.image valueForKey:@"image"];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSMutableSet *)cachedDates
{
	if (!_cachedDates)
		_cachedDates = [[NSMutableSet alloc] init];
	return _cachedDates;
}

#pragma mark - Calendar DataSource
- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldMarkDate:(NSDate *)date
{
	NSAssert(self.recurrenceRule, @"Recurrence Rule NOT set");
	if (!self.recurrenceRule)
		return NO;
	
	if (!self.date)
	{
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		calendar.locale = [NSLocale currentLocale];

		self.date = [NSDate date];
		NSInteger comps = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);

		NSDateComponents *dc = [calendar components:comps fromDate: self.date];
		self.date = [calendar dateFromComponents:dc];
		if ([self.recurrenceRule dateMatchesRules:self.date])
			[self.cachedDates addObject:self.date];
//		dc = [[NSDateComponents alloc] init];
//		[dc setDay:-self.recurrenceRule.interval];
//		self.date = [calendar dateByAddingComponents:dc toDate:self.date options:0];
		self.date = [self.recurrenceRule nextDate:self.date];
		[self.cachedDates addObject:self.date];
	}

	while ([self.date compare:date] < NSOrderedSame)
	{
		self.date = [self.recurrenceRule nextDate:self.date];
		[self.cachedDates addObject:self.date];
	}

	return [self.cachedDates containsObject:date];
	//BOOL ret = ([self.date compare:date] == NSOrderedSame);
//	return ([self.date compare:date] == NSOrderedSame);
}

//- (BOOL)datePickerView:(RSDFDatePickerView *)view isCompletedAllTasksOnDate:(NSDate *)date

@end
