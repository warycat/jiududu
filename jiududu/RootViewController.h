//
//  RootViewController.h
//  jiududu
//
//  Created by Larry on 2/15/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Issue+NKIssue.h"

@interface RootViewController : UIViewController <UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;

@property (strong, nonatomic) Issue *issue;

@end
