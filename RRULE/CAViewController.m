//
//  CAViewController.m
//  RRULE
//
//  Created by Jochen Schöllig on 24.04.13.
//  Copyright (c) 2013 Jochen Schöllig. All rights reserved.
//

#import "CAViewController.h"
#import <EventKit/EventKit.h>

#import "EKRecurrenceRule+RRULE.h"
#import "EKRecurrenceRule+HumanDescription.h"
#import "RHReccurenceRuleViewController.h"
#import "RHCalendarViewController.h"

@interface CAViewController () <RHRecurrenceRuleViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) NSIndexPath *editingIndex;

@end

@implementation CAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)list
{
	if (!_list)
	{
		_list = [[NSMutableArray alloc] init];
		[_list addObject:[[EKRecurrenceRule alloc] initWithString:@"FREQ=DAILY;"]];
		[_list addObject:[[EKRecurrenceRule alloc] initWithString:@"FREQ=DAILY;INTERVAL=2;"]];
		[_list addObject:[[EKRecurrenceRule alloc] initWithString:@"FREQ=WEEKLY;BYDAY=TU,TH;"]];
		[_list addObject:[[EKRecurrenceRule alloc] initWithString:@"FREQ=WEEKLY;BYDAY=WE,FR;"]];
		[_list addObject:[[EKRecurrenceRule alloc] initWithString:@"FREQ=WEEKLY;BYDAY=TU,TH;INTERVAL=2;"]];
		[_list addObject:[[EKRecurrenceRule alloc] initWithString:@"FREQ=WEEKLY;BYDAY=WE,FR;INTERVAL=2;"]];
		[_list addObject:[[EKRecurrenceRule alloc] initWithString:@"FREQ=MONTHLY;"]];
		[_list addObject:[[EKRecurrenceRule alloc] initWithString:@"FREQ=MONTHLY;INTERVAL=2;"]];
	}
	return _list;
}

- (RHReccurenceRuleViewController *)ruleViewController
{
	//http://stackoverflow.com/questions/9575702/segue-to-another-storyboard
	// Get the storyboard named secondStoryBoard from the main bundle:
	UIStoryboard *recurrenceRuleChooserStoryboard = [UIStoryboard storyboardWithName:@"RHRecurrenceRuleChooser" bundle:nil];

	// Load the initial view controller from the storyboard.
	// Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
	RHReccurenceRuleViewController *recurrenceChooserViewController = [recurrenceRuleChooserStoryboard instantiateInitialViewController];
	recurrenceChooserViewController.delegate = self;
	//
	// **OR**
	//
	// Load the view controller with the identifier string myTabBar
	// Change UIViewController to the appropriate class
	//	UIViewController *theTabBar = (UIViewController *)[secondStoryBoard instantiateViewControllerWithIdentifier:@"myTabBar"];
	return recurrenceChooserViewController;
}

- (IBAction)addRecurrenceRule:(UIBarButtonItem *)sender
{
	self.editingIndex = nil;
	// Then push the new view controller in the usual way:
//	[self.navigationController pushViewController:recurrenceChooserViewController animated:YES];
	[self presentViewController:[self ruleViewController] animated:YES completion:nil];
}

- (void)recurrenceRuleCreated:(EKRecurrenceRule *)rule
{
	if (self.editingIndex)
	{
		[self.list replaceObjectAtIndex:self.editingIndex.row withObject:rule];
		[self.tableView beginUpdates];
		[self.tableView reloadRowsAtIndexPaths:@[self.editingIndex] withRowAnimation:UITableViewRowAnimationNone];
		[self.tableView endUpdates];
	}
	else
		[self.list addObject:rule];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//	if ([segue.identifier isEqualToString:@"AddRecurrenceRule"])
//	{
//		UIViewController *controller = segue.destinationViewController;
//		controller.dataController = self.dataController;
//		RHParentCell *cell = (RHParentCell *)sender;
//		controller.parentInfo = cell.parentRecord;
//	}
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//	calendar.locale = [NSLocale currentLocale];

	RHCalendarViewController *calendarView = [[RHCalendarViewController alloc] init];//WithCalendar:calendar];
	calendarView.recurrenceRule = [self.list objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:calendarView animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	RHReccurenceRuleViewController *ruleViewController = [self ruleViewController];

	self.editingIndex = indexPath;
	EKRecurrenceRule *rule = [self.list objectAtIndex:indexPath.row];
	[ruleViewController setEditRule:rule];

	[self.navigationController pushViewController:ruleViewController animated:YES];

//	UIStoryboardSegue *segue = [UIStoryboardSegue segueWithIdentifier:@"identifier" source:self destination:destination performHandler:^(void) {
//		//view transition/animation
//		[self.navigationController pushViewController:destination animated:YES];
//	}];

//	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//	[self shouldPerformSegueWithIdentifier:segue.identifier sender:cell];//optional
//	[self prepareForSegue:segue sender:cell];

//	[self.navigationController pushViewController:destination animated:YES];
//	[segue perform];
}

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section > 0)
		return 0;
	return [self.list count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	EKRecurrenceRule *rule = [self.list objectAtIndex:indexPath.row];
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RuleCell" forIndexPath:indexPath];
	cell.textLabel.text = [rule humanDescription];
	NSString *desc = [rule description];
	desc = [desc substringFromIndex:NSMaxRange([desc rangeOfString:@"RRULE"])];
	cell.detailTextLabel.text = desc;
	return cell;
}

@end
