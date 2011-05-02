//
//  DemoTableViewController.m
//  RTLabelProject
//
/**
 * Copyright (c) 2010 Muh Hon Cheng
 * Created by honcheng on 1/6/11.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining 
 * a copy of this software and associated documentation files (the 
 * "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, 
 * distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject 
 * to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT 
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR 
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author 		Muh Hon Cheng <honcheng@gmail.com>
 * @copyright	2011	Muh Hon Cheng
 * @version
 * 
 */

#import "DemoTableViewController.h"
#import "DemoTableViewCell.h"
#import "RTLabel.h"

@implementation DemoTableViewController
@synthesize dataArray;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style 
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,150,30)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setTextColor:[UIColor whiteColor]];
		[titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20]];
		[titleLabel setText:@"RTLabel"];
		[self.navigationItem setTitleView:titleLabel];
		[titleLabel release];
		[titleLabel setTextAlignment:UITextAlignmentCenter];
		
		self.dataArray = [NSMutableArray array];
		NSMutableDictionary *row1 = [NSMutableDictionary dictionary];
		[row1 setObject:@"<b>bold</b> and <i>italic</i> style" forKey:@"text"];
		[self.dataArray addObject:row1];
		
		NSMutableDictionary *row2 = [NSMutableDictionary dictionary];
		[row2 setObject:@"<font face='HelveticaNeue-CondensedBold' size=20><u color=blue>underlined</u> <uu color=red>text</uu></font>" forKey:@"text"];
		[self.dataArray addObject:row2];
		
		NSMutableDictionary *row3 = [NSMutableDictionary dictionary];
		[row3 setObject:@"clickable link - <a href='http://www.google.com'>google.com</a>" forKey:@"text"];
		[self.dataArray addObject:row3];
        
        NSMutableDictionary *row4 = [NSMutableDictionary dictionary];
		[row4 setObject:@"<font face='HelveticaNeue-CondensedBold' size=20 color='#CCFF00'>Text with</font> <font face=AmericanTypewriter size=16 color=purple>different colours</font> <font face=Futura size=32 color='#dd1100'>and sizes</font>" forKey:@"text"];
		[self.dataArray addObject:row4];
        
        NSMutableDictionary *row5 = [NSMutableDictionary dictionary];
		[row5 setObject:@"<font face='HelveticaNeue-CondensedBold' size=20 stroke=1>Text with strokes</font> " forKey:@"text"];
		[self.dataArray addObject:row5];
        
        NSMutableDictionary *row6 = [NSMutableDictionary dictionary];
		[row6 setObject:@"<font face='HelveticaNeue-CondensedBold' size=20 kern=35>KERN</font> " forKey:@"text"];
		[self.dataArray addObject:row6];
		
		NSMutableDictionary *row20 = [NSMutableDictionary dictionary];
		[row20 setObject:@"<p indent=20>Indented bla bla bla bla bla bla bla bla bla bla bla bla bla</p>" forKey:@"text"];
		[self.dataArray addObject:row20];
    }
    return self;
}



#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *rowInfo = [self.dataArray objectAtIndex:indexPath.row];
	if ([rowInfo objectForKey:@"cell_height"])
	{
		return [[rowInfo objectForKey:@"cell_height"] intValue];
	}
	else 
	{
		RTLabel *rtLabel = [DemoTableViewCell textLabel];
		[rtLabel setText:[rowInfo objectForKey:@"text"]];
		CGSize optimumSize = [rtLabel optimumSize];
		[rowInfo setObject:[NSNumber numberWithInt:optimumSize.height+20] forKey:@"cell_height"];
		return [[rowInfo objectForKey:@"cell_height"] intValue];
	}

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DemoTableViewCell";
    DemoTableViewCell *cell = (DemoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[DemoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	[cell.rtLabel setText:[[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"text"]];
    return cell;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[self.dataArray release];
    [super dealloc];
}


@end

