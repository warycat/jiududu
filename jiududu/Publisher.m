//
//  Publisher.m
//  jiududu
//
//  Created by Larry on 2/19/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import "Publisher.h"

@implementation Publisher

+ (Publisher *)sharedPublisher
{
    static Publisher *sharedPublisher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPublisher = [[self alloc]init];
    });
    return sharedPublisher;
}

- (void)loadIssuesFromURL:(NSURL *)URL withHandler:(void (^)(NSDictionary *))handler
{
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!data) {
                                   return ;
                               }
                               NSDictionary *issues = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                               handler(issues);
                           }];
}

- (void)subscribeProductId:(NSString *)productId
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithObject:productId]];
    productsRequest.delegate = self;
    [productsRequest start];
    [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
}

- (void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"%s",sel_getName(_cmd));
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%s %@",sel_getName(_cmd), error);
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"%s",sel_getName(_cmd));
    NSLog(@"%@",response.products);
    for (SKProduct *product in response.products) {
        NSLog(@"%@",product.productIdentifier);
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue]addPayment:payment];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"%s",sel_getName(_cmd));
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
            {
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                NSLog(@"failed");
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
            {
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                NSLog(@"ok");
            }
                break;
            default:
                break;
        }
    }
}

@end
