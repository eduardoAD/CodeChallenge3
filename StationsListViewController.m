//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface StationsListViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSArray *stationBeanList;
@property NSDictionary *selectedStation;
@property CLLocationManager *myLocationManager;
@property CLPlacemark *currentLocation;

@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stationBeanList = [[NSArray alloc]init];
    [self searchCurrentLocation];

    NSURL *stringUrl = [NSURL URLWithString:@"http://www.divvybikes.com/stations/json/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:stringUrl];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        self.stationBeanList = [((NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]) objectForKey:@"stationBeanList"];
        [self.tableView reloadData];
    }];
}

#pragma mark - Localization

- (void)searchCurrentLocation{
    self.myLocationManager = [[CLLocationManager alloc] init];
    [self.myLocationManager requestWhenInUseAuthorization];
    self.myLocationManager.delegate = self;

    [self.myLocationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    for (CLLocation *location in locations) {
        if(location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000){
            [self reverseGeocode:location];
            [self.myLocationManager stopUpdatingLocation];
            break;
        }
    }
}

- (void)reverseGeocode:(CLLocation *)location{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        self.currentLocation = placemarks.firstObject;
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
    NSString *bikes =[[(NSDictionary *)[self.stationBeanList objectAtIndex:indexPath.row] objectForKey:@"availableBikes"] description];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ bikes availables",bikes];
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
    destination.currentLocation = self.currentLocation;
}

#pragma mark - Search bar

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self handleSearch:searchBar];
}

- (void)handleSearch:(UISearchBar *)searchBar {
    NSLog(@"User searched for %@", searchBar.text);
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"*User searched for %@", searchBar.text);
}
@end
