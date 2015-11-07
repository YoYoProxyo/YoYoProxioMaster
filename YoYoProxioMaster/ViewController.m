//
//  ViewController.m
//  YoYoProxioMaster
//
//  Created by Tom Ridd on 07/11/2015.
//  Copyright © 2015 Tom Ridd. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+animatedGIF.h"
#import <EstimoteSDK/EstimoteSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Roadtrip.h"

#define RADIUS 1.0
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *gears;
@property (weak, nonatomic) IBOutlet UIImageView *alarmImage;

@property (nonatomic, copy)     void (^completion)(CLBeacon *);

@property (nonatomic, assign)   ESTScanType scanType;
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *region;
@property (nonatomic, strong) NSArray *beaconsArray;
@property (weak, nonatomic) IBOutlet UIView *alarmOff;
@property (weak, nonatomic) IBOutlet UIView *alarmOn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set loading image running
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Sadi" withExtension:@"gif"];
    self.gears.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:@"Leonardo" withExtension:@"gif"];
    self.alarmImage.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url2]];
    
    self.alarmOff.layer.cornerRadius = 25;
    self.alarmOff.layer.masksToBounds = YES;

    self.alarmOn.layer.cornerRadius = 25;
    self.alarmOn.layer.masksToBounds = YES;
    
    [self initialiseEstimote];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initialiseEstimote {
    
    self.scanType = ESTScanTypeBeacon;
    self.completion = ^(CLBeacon *beacon) {
        [ViewController completionHandler:beacon];
    };
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*
     * Starts looking for Estimote beacons.
     * All callbacks will be delivered to beaconManager delegate.
     */
    if (self.scanType == ESTScanTypeBeacon)
    {
        /*
         * Creates sample region object (you can additionaly pass major / minor values).
         *
         * We specify it using only the ESTIMOTE_PROXIMITY_UUID because we want to discover all
         * hardware beacons with Estimote's proximty UUID.
         */
        self.region = [[CLBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                         identifier:@"EstimoteSampleRegion"];
        
        self.beaconManager = [[ESTBeaconManager alloc] init];
        self.beaconManager.delegate = self;
        
        NSLog(@"Start ranging");
        [self startRangingBeacons];
    }
}

-(void)startRangingBeacons
{
    NSLog(@"%d", [ESTBeaconManager authorizationStatus]);
    
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        [self.beaconManager requestAlwaysAuthorization];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Access Denied"
                                                        message:@"You have denied access to location services. Change this in app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
                                                        message:@"You have no access to location services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /*
     *Stops ranging after exiting the view.
     */
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
}

#pragma mark - ESTBeaconManager delegate

-(void) beaconManager:(id)manager didStartMonitoringForRegion:(CLBeaconRegion *)region {
    NSLog(@"Starting monitoring for region %@", region.major);
}
- (void)beaconManager:(id)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusDenied )
    {
        [self.beaconManager startRangingBeaconsInRegion:self.region];
    }
}

- (void)beaconManager:(id)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Ranging error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Monitoring error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{

    
    CLBeacon* minBeacon = nil;
    NSUInteger strength = 0;
    self.beaconsArray = beacons;
    
    BOOL alarm = NO;
    for (CLBeacon* beacon in beacons) {
        if (beacon.accuracy >= 0 && beacon.accuracy < RADIUS) {
            alarm = YES;
            [self setAlarmState:beacon];
            return;
        }
    }
    [self deactivateAlarmState];
}

- (BOOL) beaconIsActive:(CLBeacon*) beacon {
    if ([beacon.minor isEqualToNumber:@18810]) {
        return YES;
    }
    return NO;
}
- (void) setAlarmState:(CLBeacon*) beacon {
    [self.alarmOff setHidden:YES];
    [self.alarmOn setHidden:NO];
    
    self.view.backgroundColor = [UIColor YoyoAlarm];
}
- (void) deactivateAlarmState {
    [self.alarmOff setHidden:NO];
    [self.alarmOn setHidden:YES];
    
    self.view.backgroundColor = [UIColor YoyoBackground];
}

+ (void) completionHandler:(CLBeacon*) beacon {
    NSLog(@"%@", beacon);

}


@end
