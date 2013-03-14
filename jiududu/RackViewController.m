//
//  RackViewController.m
//  jiududu
//
//  Created by Larry on 2/17/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import "RackViewController.h"
#import "AppDelegate.h"
#import "Issue+NKIssue.h"
#import "Publisher.h"
#import "BlockAlertView.h"
#import "BlockActionSheet.h"
#import "RootViewController.h"

@interface RackViewController ()
@property (weak, nonatomic) IBOutlet iCarousel *iCarousel;
@property (nonatomic, strong) AppDelegate *app;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;
@end

@implementation RackViewController

- (AppDelegate *)app
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    return app;
}

- (void)setupBackgroundImage
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height == 480)
        {
            self.backgroundView.image = [UIImage imageNamed:@"Default.png"];
        }
        if (result.height == 568) {
            self.backgroundView.image = [UIImage imageNamed:@"Default-568h.png"];
        }
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            self.backgroundView.image = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
        }else{
            self.backgroundView.image = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
        }
    }
}

- (void)setupiCarousel
{
    self.managedObjectContext = self.app.managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Issue"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController performFetch:nil];
    self.iCarousel.type = iCarouselTypeTimeMachine;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.iCarousel.scrollSpeed = 2.0f;
        self.iCarousel.bounceDistance = 0.3f;
    }else{
        self.iCarousel.bounceDistance = 0.7f;
    }
    self.iCarousel.delegate = self;
    self.iCarousel.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateFeed) name:@"content-available" object:nil];
    [self setupBackgroundImage];
    [self setupiCarousel];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.iCarousel reloadItemAtIndex:self.iCarousel.currentItemIndex animated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return;
    }
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            self.backgroundView.image = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            self.backgroundView.image = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
            break;
        default:
            break;
    }
}

- (void)updateFeed
{
#ifdef DEBUG
    NSURL *URL = [NSURL URLWithString:@"http://dev.warycat.com/jiududu/issues.php"];
#else
    NSURL *URL = [NSURL URLWithString:@"http://aws.warycat.com/jiududu/issues.php"];
#endif
    [[Publisher sharedPublisher]loadIssuesFromURL:URL withHandler:^(NSDictionary *feed) {
        NSArray *entry = [feed objectForKey:@"Entry"];
        NSString *host = [feed objectForKey:@"Host"];
        for (NSDictionary *issue in entry) {
            NSString *content = [issue objectForKey:@"Content"];
            NSString *cover = [issue objectForKey:@"Cover"];
            NSString *name = [issue objectForKey:@"Name"];
            NSNumber *date = [issue objectForKey:@"Date"];
            NSString *title = [issue objectForKey:@"Title"];
            NSString *version = [issue objectForKey:@"Version"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Issue"];
            fetchRequest.predicate = predicate;
            Issue *issue = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil].lastObject;
            if (issue) {
                if ([issue.nkIssue.name isEqualToString:[Publisher sharedPublisher].issue] && issue.nkIssue.status == NKIssueContentStatusNone) {
                    [[UIApplication sharedApplication] setNewsstandIconImage:[UIImage imageWithData:issue.cover]];
                    [issue download];
                    [Publisher sharedPublisher].issue = nil;
                }
                NSLog(@"%@ exist",issue.name);
                continue ;
            }
            NSLog(@"%@ add",issue.name);
            NSURL *coverURL = [NSURL URLWithString:[host stringByAppendingString:cover]];
            NSURLRequest *coverRequest = [NSURLRequest requestWithURL:coverURL];
            [NSURLConnection sendAsynchronousRequest:coverRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
                UIImage *image = [UIImage imageWithData:data];
                if (http.statusCode == 200 && image) {
                    Issue *issue = [NSEntityDescription insertNewObjectForEntityForName:@"Issue"
                                                                 inManagedObjectContext:self.managedObjectContext];
                    issue.cover = data;
                    issue.name = name;
                    issue.date = [NSDate dateWithTimeIntervalSince1970:date.integerValue];
                    issue.content = [host stringByAppendingString:content];
                    issue.version = version;
                    issue.title = title;
                    [self.app saveContext];
                    if ([issue.nkIssue.name isEqualToString:[Publisher sharedPublisher].issue] && issue.nkIssue.status == NKIssueContentStatusNone) {
                        [[UIApplication sharedApplication] setNewsstandIconImage:image];
                        [issue download];
                        [Publisher sharedPublisher].issue = nil;
                    }
                }
            }];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateFeed];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setICarousel:nil];
    [super viewDidUnload];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    Issue *issue = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
    UIImageView *imageView = nil;
    UIProgressView *progressView = nil;
    UIActivityIndicatorView *indicatorView = nil;
    if (view == nil) {
        view = [[UIView alloc]initWithFrame:[self frame]];
        view.clipsToBounds = YES;
        imageView = [[UIImageView alloc]initWithFrame:[self frame]];
        imageView.tag = 1;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        [view addSubview:imageView];
        
        progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.tag = 2;
        [view addSubview:progressView];
        
        indicatorView = [[UIActivityIndicatorView alloc]initWithFrame:self.view.bounds];
        indicatorView.tag = 3;
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        indicatorView.hidesWhenStopped = YES;
        [view addSubview:indicatorView];
    }
    view.frame = [self frame];
    imageView = (UIImageView *) [view viewWithTag:1];
    progressView = (UIProgressView *) [view viewWithTag:2];
    indicatorView = (UIActivityIndicatorView *) [view viewWithTag:3];
    [indicatorView startAnimating];
    imageView.image = [UIImage imageWithData:issue.cover];    
    CGRect imageRect;
    CGFloat aspectRatioX = imageView.bounds.size.width/imageView.image.size.width;
    CGFloat aspectRatioY = imageView.bounds.size.height/imageView.image.size.height;
    if ( aspectRatioX < aspectRatioY )
        imageRect = CGRectMake(0, (imageView.bounds.size.height - aspectRatioX*imageView.image.size.height)*0.5f, imageView.bounds.size.width, aspectRatioX*imageView.image.size.height);
    else
        imageRect = CGRectMake((imageView.bounds.size.width - aspectRatioY*imageView.image.size.width)*0.5f, 0, aspectRatioY*imageView.image.size.width, imageView.bounds.size.height);
    progressView.frame = imageRect;
    
    if ([issue.status isEqualToString:@"None"]) {
        progressView.hidden = YES;
    }else if ([issue.status isEqualToString:@"Downloading"]){
        progressView.hidden = NO;
        progressView.progress = issue.progress.floatValue;
    }else if ([issue.status isEqualToString:@"Processing"]){
        progressView.hidden = NO;
        progressView.progress = issue.percentage.floatValue / 100.0f;
    }else if ([issue.status isEqualToString:@"Ready"]){
        progressView.hidden = YES;
        [indicatorView stopAnimating];
    }else{
        NSLog(@"error");
    }
    return view;
}

- (CGRect)frame
{
    return self.view.bounds;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.iCarousel reloadData];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    Issue *issue = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
//    NSLog(@"%@",issue.nkIssue);
    if ([issue.status isEqualToString:@"None"]) {
        NSLog(@"none");
        [issue download];
        return;
    }
    if ([issue.status isEqualToString:@"Downloading"]) {
        NSLog(@"downloading");
        BlockActionSheet *action = [[BlockActionSheet alloc]initWithTitle:nil];
        [action setDestructiveButtonWithTitle:NSLocalizedString(@"Delete", nil) block:^{
            [issue remove];
        }];
        [action setCancelButtonWithTitle:NSLocalizedString(@"Cancel",nil) block:nil];
        [action showInView:self.view];
        return;
    }
    if ([issue.status isEqualToString:@"Processing"]) {
        NSLog(@"processing");
        return;
    }
    if ([issue.status isEqualToString:@"Ready"]) {
        NSLog(@"ready");
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateStyle = NSDateFormatterLongStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        BlockAlertView *alertView = [BlockAlertView alertWithTitle:[formatter stringFromDate:issue.date] message:issue.title];
        [alertView setCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil) block:^{
            NSLog(@"cancel");
        }];
        [alertView setDestructiveButtonWithTitle:NSLocalizedString(@"Delete", nil) block:^{
            [issue remove];
        }];
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        if ([version compare:issue.version options:NSNumericSearch] == NSOrderedAscending) {
            [alertView addButtonWithTitle:@"Update" block:^{
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/jiu-dou-du/id604696222?ls=1&mt=8"]];
            }];
        }else{
            [alertView addButtonWithTitle:NSLocalizedString(@"Open", nil) block:^{
                [self performSegueWithIdentifier:@"OpenSegue" sender:issue];
            }];
        }
        [alertView show];
        return;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"OpenSegue"]) {
        RootViewController *rvc = segue.destinationViewController;
        rvc.issue = sender;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.iCarousel insertItemAtIndex:newIndexPath.row animated:YES];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.iCarousel removeItemAtIndex:indexPath.row animated:YES];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.iCarousel reloadItemAtIndex:indexPath.row animated:NO];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.iCarousel removeItemAtIndex:indexPath.row animated:YES];
                [self.iCarousel insertItemAtIndex:newIndexPath.row animated:YES];
                break;
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        return YES;
    }else{
        return toInterfaceOrientation == UIInterfaceOrientationPortrait;
    }
}

@end
