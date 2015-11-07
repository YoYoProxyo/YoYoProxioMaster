//
//  ViewController.m
//  YoYoProxioMaster
//
//  Created by Tom Ridd on 07/11/2015.
//  Copyright © 2015 Tom Ridd. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+animatedGIF.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *gears;

@property NSNumber* channel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set loading image running
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Sadi" withExtension:@"gif"];
    self.gears.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
