//
//  ViewController.h
//  WhereIAm
//
//  Created by Harel Avikasis on 19/08/15.
//  Copyright (c) 2015 Harel Avikasis. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface ViewController : UIViewController 
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *textAddress;

- (IBAction)pickPlace:(UIButton *)sender;



@end

