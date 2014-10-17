//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *myLocationManager;
@property CLPlacemark *currentLocation;
@property NSArray *stringDirections;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self searchCurrentLocation];
}

- (void)searchCurrentLocation{
    self.myLocationManager = [[CLLocationManager alloc] init];
    [self.myLocationManager requestWhenInUseAuthorization];
    self.myLocationManager.delegate = self;

    [self.myLocationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Failed to Get Your Location"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
    NSLog(@"Error: %@",error);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if (annotation == mapView.userLocation) {
        return nil;
    }
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.image = [UIImage imageNamed:@"bikeImage"];

    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    CLLocationCoordinate2D coord1;
    coord1.latitude = [[self.stationBike objectForKey:@"latitude"] doubleValue];
    coord1.longitude = [[self.stationBike objectForKey:@"longitude"] doubleValue];
    MKPlacemark *placemark1 = [[MKPlacemark alloc] initWithCoordinate:coord1 addressDictionary:nil];
    MKMapItem *dest = [[MKMapItem alloc]initWithPlacemark:placemark1];

    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = dest;
    request.transportType = MKDirectionsTransportTypeWalking;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {
         MKRoute *route = response.routes.firstObject;
         self.stringDirections = [[NSArray alloc]initWithArray:route.steps];
     }];
    NSMutableString *message = [[NSMutableString alloc]init];
    for (MKRouteStep *step in self.stringDirections) {
        //NSLog(@"Step: %@", step.instructions);
        [message appendString:step.instructions];
        [message appendString:@"\n"];
    }
    UIAlertView *textualDirections = [[UIAlertView alloc] initWithTitle:@"Directions"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
    [textualDirections show];
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

        [self addAnnotation];
        [self zoomIn];
    }];
}

- (void)addAnnotation{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    CLLocationCoordinate2D coord;
    coord.latitude = [[self.stationBike objectForKey:@"latitude"] doubleValue];
    coord.longitude = [[self.stationBike objectForKey:@"longitude"] doubleValue];
    annotation.coordinate = coord;
    annotation.title = [self.stationBike objectForKey:@"stAddress1"];
    annotation.subtitle = [[self.stationBike objectForKey:@"availableBikes"] description];

    [self.mapView addAnnotation:annotation];
}

- (void)zoomIn{
    CLLocationCoordinate2D zoom;
    zoom.latitude = [[self.stationBike objectForKey:@"latitude"] doubleValue];
    zoom.longitude = [[self.stationBike objectForKey:@"longitude"] doubleValue];

    MKCoordinateSpan span;
    span.latitudeDelta = .05;
    span.longitudeDelta = .05;

    MKCoordinateRegion region;
    region.center = zoom;
    region.span = span;
    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
}


@end
