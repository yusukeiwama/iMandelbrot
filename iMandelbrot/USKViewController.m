//
//  USKViewController.m
//  iMandelbrot
//
//  Created by Yusuke Iwama on 10/25/13.
//  Copyright (c) 2013 Yusuke Iwama. All rights reserved.
//

#import "USKViewController.h"

@interface USKViewController () {
	USKFractalView *fractalView;
	UILabel *magnificationLabel;
}

@end

@implementation USKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	fractalView = [[USKFractalView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width)];
	fractalView.delegate = self;
	fractalView.center = self.view.center;
	[self.view addSubview:fractalView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[backButton addTarget:fractalView action:@selector(drawMandelbrotSet) forControlEvents:UIControlEventTouchUpInside];
	backButton.frame = CGRectMake(20, [[UIScreen mainScreen] bounds].size.height - 68, [[UIScreen mainScreen] bounds].size.width - 40, 44);
	[backButton setTitle:@"Back" forState:UIControlStateNormal];
	[self.view addSubview:backButton];
	
	magnificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, [[UIScreen mainScreen] bounds].size.width - 40, 44)];
	magnificationLabel.textAlignment = NSTextAlignmentRight;
	magnificationLabel.adjustsFontSizeToFitWidth = YES;
	magnificationLabel.font = [UIFont fontWithName:@"Helvetica" size:44];
	[self updateMagnificationLabel];
	[self.view addSubview:magnificationLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateMagnificationLabel
{
	magnificationLabel.text = [NSString stringWithFormat:@"x%.1f", fractalView.currentMagnification];
}

@end
