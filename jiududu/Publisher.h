//
//  Publisher.h
//  jiududu
//
//  Created by Larry on 2/19/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <NewsstandKit/NewsstandKit.h>

@interface Publisher : NSObject<SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>

+ (Publisher *)sharedPublisher;
- (void)loadIssuesFromURL:(NSURL *)URL withHandler:(void (^)(NSDictionary *issues))handler;
- (void)subscribeProductId:(NSString *)productId;

@end
