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

@interface CAViewController ()

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

- (IBAction)addRecurrenceRule:(UIBarButtonItem *)sender
{
	// Get the storyboard named secondStoryBoard from the main bundle:
	UIStoryboard *recurrenceRuleChooserStoryboard = [UIStoryboard storyboardWithName:@"RHRecurrenceRuleChooser" bundle:nil];

	// Load the initial view controller from the storyboard.
	// Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
	UIViewController *recurrenceChooserViewController = [recurrenceRuleChooserStoryboard instantiateInitialViewController];
	//
	// **OR**
	//
	// Load the view controller with the identifier string myTabBar
	// Change UIViewController to the appropriate class
//	UIViewController *theTabBar = (UIViewController *)[secondStoryBoard instantiateViewControllerWithIdentifier:@"myTabBar"];

	// Then push the new view controller in the usual way:
//	[self.navigationController pushViewController:recurrenceChooserViewController animated:YES];
	[self presentViewController:recurrenceChooserViewController animated:YES completion:nil];
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

@end
