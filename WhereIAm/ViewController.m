//
//  ViewController.m
//  WhereIAm
//
//  Created by Harel Avikasis on 19/08/15.
//  Copyright (c) 2015 Harel Avikasis. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () <GMSMapViewDelegate , UITextFieldDelegate>

@end

@implementation ViewController
@synthesize mapView, nameLabel, addressLabel, textAddress;

GMSPlacesClient *_placesClient;
GMSPlacePicker *_placePicker;
GMSPlace *placeA;
GMSMarker *marker;



- (void)viewDidLoad {
    [super viewDidLoad];
    mapView.delegate=self;
    textAddress.delegate = self;
     _placesClient = [[GMSPlacesClient alloc] init];
    marker = [[GMSMarker alloc] init];
    

    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        self.nameLabel.text = @"No current place";
        self.addressLabel.text = @"";
        
        if (placeLikelihoodList != nil) {
            placeA = [[[placeLikelihoodList likelihoods] firstObject] place];
            
            if (placeA != nil) {
                self.nameLabel.text = placeA.name;
                self.addressLabel.text = [[placeA.formattedAddress componentsSeparatedByString:@", "]
                                          componentsJoinedByString:@"\n"];
                CLLocationCoordinate2D target = CLLocationCoordinate2DMake(placeA.coordinate.latitude, placeA.coordinate.longitude);
                [self.mapView animateToLocation:target];
                [self.mapView animateToZoom:17];
                marker.position = CLLocationCoordinate2DMake(placeA.coordinate.latitude, placeA.coordinate.longitude);
                marker.map = self.mapView;
            }
        }
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (IBAction)pickPlace:(UIButton *)sender {

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(placeA.coordinate.latitude, placeA.coordinate.longitude);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001,
                                                                  center.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001,
                                                                  center.longitude - 0.001);
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            self.nameLabel.text = place.name;
            self.addressLabel.text = [[place.formattedAddress
                                       componentsSeparatedByString:@", "] componentsJoinedByString:@"\n"];
            CLLocationCoordinate2D target = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
            [self.mapView animateToLocation:target];
            [self.mapView animateToZoom:17];
            marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
            marker.map = self.mapView;
        } else {
            self.nameLabel.text = @"No place selected";
            self.addressLabel.text = @"";
        }
    }];
}
- (void)placeAutocomplete:(UITextField *)textField {
    
    GMSVisibleRegion visibleRegion = self.mapView.projection.visibleRegion;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:visibleRegion.farLeft
                                                                       coordinate:visibleRegion.nearRight];
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterCity;
    
    [_placesClient autocompleteQuery:@"Sydney Oper"/*textField.text*/
                              bounds:bounds
                              filter:filter
                            callback:^(NSArray *results, NSError *error) {
                                if (error != nil) {
                                    NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                    return;
                                }
                                
                                for (GMSAutocompletePrediction* result in results) {
                                    NSLog(@"Result '%@' with placeID %@", result.attributedFullText.string, result.placeID);
                                }
                            }];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -230; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self placeAutocomplete:textField];
    [textField resignFirstResponder];
    return YES;
}

@end
