//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property MKMapItem *source;
@property MKMapItem *destination;
@property NSMutableString *message;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CLLocationCoordinate2D coord1;
    coord1.latitude = self.currentLocation.location.coordinate.latitude;
    coord1.longitude = self.currentLocation.location.coordinate.longitude;
    MKPlacemark *placemark1 = [[MKPlacemark alloc] initWithCoordinate:coord1 addressDictionary:nil];
    self.source = [[MKMapItem alloc]initWithPlacemark:placemark1];

    CLLocationCoordinate2D coord2;
    coord2.latitude = [[self.stationBike objectForKey:@"latitude"] doubleValue];
    coord2.longitude = [[self.stationBike objectForKey:@"longitude"] doubleValue];
    MKPlacemark *placemark2 = [[MKPlacemark alloc] initWithCoordinate:coord2 addressDictionary:nil];
    self.destination = [[MKMapItem alloc]initWithPlacemark:placemark2];

    self.message = [[NSMutableString alloc]init];

    [self getDirections];
    [self addAnnotation];
    [self zoomIn];
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

-(void)getDirections{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = self.source;
    request.destination = self.destination;
    request.transportType = MKDirectionsTransportTypeWalking;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {
         for (MKRoute *route in response.routes) {
             for (MKRouteStep *step in route.steps) {
                 [self.mapView addOverlay:[step polyline] level:MKOverlayLevelAboveRoads];
                 [self.message appendString:step.instructions];
                 [self.message appendString:@"\n"];
             }
         }
     }];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    UIAlertView *textualDirections = [[UIAlertView alloc] initWithTitle:@"Directions"
                                                                message:self.message
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
    textualDirections.delegate = self;
    [textualDirections show];
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

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor blueColor];
        return routeRenderer;
    }
    else return nil;
}

@end
