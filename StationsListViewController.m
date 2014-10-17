//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "MapViewController.h"

@interface StationsListViewController () <UITabBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSArray *stationBeanList;
@property NSDictionary *selectedStation;

@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stationBeanList = [[NSArray alloc]init];

    NSURL *stringUrl = [NSURL URLWithString:@"http://www.divvybikes.com/stations/json/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:stringUrl];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        self.stationBeanList = [((NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]) objectForKey:@"stationBeanList"];
        [self.tableView reloadData];
    }];
}


#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stationBeanList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = [(NSDictionary *)[self.stationBeanList objectAtIndex:indexPath.row] objectForKey:@"stAddress1"];
    cell.detailTextLabel.text = [[(NSDictionary *)[self.stationBeanList objectAtIndex:indexPath.row] objectForKey:@"availableBikes"] description];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedStation = [self.stationBeanList objectAtIndex:indexPath.row];

    [self performSegueWithIdentifier:@"ToMapSegue" sender:tableView];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MapViewController *destination = [segue destinationViewController];
    destination.stationBike = self.selectedStation;
}

@end
