//
//  RackViewController.h
//  jiududu
//
//  Created by Larry on 2/17/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface RackViewController : UIViewController <NSFetchedResultsControllerDelegate,iCarouselDataSource,iCarouselDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@property BOOL debug;
@end
