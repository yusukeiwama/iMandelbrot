//
//  USKViewController.m
//  iMandelbrot
//
//  Created by Yusuke Iwama on 10/25/13.
//  Copyright (c) 2013 Yusuke Iwama. All rights reserved.
//

#import "USKViewController.h"
#import "USKFractalView.h"

@interface USKViewController ()

@end

@implementation USKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	USKFractalView *iv = [[USKFractalView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width)];
	iv.center = self.view.center;
	[self.view addSubview:iv];
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[backButton addTarget:iv action:@selector(drawMandelbrotSet) forControlEvents:UIControlEventTouchUpInside];
	backButton.frame = CGRectMake(20, [[UIScreen mainScreen] bounds].size.height - 108, [[UIScreen mainScreen] bounds].size.width - 40, 88);
	[backButton setTitle:@"Back" forState:UIControlStateNormal];
	[self.view addSubview:backButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
