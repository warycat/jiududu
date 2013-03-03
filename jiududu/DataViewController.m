//
//  DataViewController.m
//  jiududu
//
//  Created by Larry on 2/15/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import "DataViewController.h"

@interface DataViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation DataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSURL *fileURL = self.dataObject;
    self.imageView.image = [UIImage imageWithContentsOfFile:fileURL.path];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}
@end
