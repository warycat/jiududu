//
//  ModelController.h
//  jiududu
//
//  Created by Larry on 2/15/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Issue+NKIssue.h"

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@property (nonatomic, strong) Issue *issue;

@end
