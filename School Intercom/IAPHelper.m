//
//  IAPHelper.m
//  School Intercom
//
//  Created by Randall Rumple on 5/3/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperProductPurchaseFailedNotification = @"IAPHelperProductPurchaseFailedNotification";
NSString *const IAPHelperProductRestoredPurchaseNotification = @"IAPHelperProductRestoredPurchaseNotification";
NSString *const IAPHelperProductRestoreCompleted = @"IAPHelperProductRestoreCompleted";
NSString *const IAPHelperProductRestoreCompletedWithNumber = @"IAPHelperProductRestoreCompletedWithNumber";



@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic) NSUInteger numberOfRestoredTransactions;
@end

@implementation IAPHelper
{
    SKProductsRequest * _productsRequest;
    
    RequestProdecutsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init]))
    {
        _productIdentifiers = productIdentifiers;
        
        _purchasedProductIdentifiers = [NSMutableSet set];
        for(NSString * productIdentifier in _productIdentifiers)
        {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if(productPurchased)
            {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
            else
            {
                NSLog(@"Not Purchased: %@", productIdentifier);
            }
        }
        
        [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
        self.numberOfRestoredTransactions = 0;
    }
    
    return self;

}

- (void)requestProductsWithCompletionHandler:(RequestProdecutsCompletionHandler)completionHandler
{
    _completionHandler = [completionHandler copy];
    
    _productsRequest =[[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded list of produts...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for(SKProduct * skProduct in skProducts)
    {
        NSLog(@"Found product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load list of products. %@", error);
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
}

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product
{
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreCompletedTransactions {
    
    
    NSLog(@"restore started");
    self.numberOfRestoredTransactions = 0;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


- (void)provideContentForProductIdentifier:(SKPaymentTransaction *)transaction
{
    [_purchasedProductIdentifiers addObject:transaction.payment.productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:transaction.payment.productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(transaction.originalTransaction != nil )
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:transaction.originalTransaction userInfo:nil];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:transaction userInfo:nil];
}


- (void)provideContentForRestoredProductIdentifier:(SKPaymentTransaction *)transaction
{
    NSLog(@"%@", transaction.payment.productIdentifier);
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:transaction.payment.productIdentifier]boolValue])
    {
        self.numberOfRestoredTransactions++;
        [_purchasedProductIdentifiers addObject:transaction.payment.productIdentifier];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:transaction.payment.productIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoredPurchaseNotification object:transaction userInfo:nil];

    }
}


#pragma mark - SKPaymentTransactionObserver delegate

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction...");
    [self provideContentForRestoredProductIdentifier:transaction.originalTransaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"failedTransaction...");
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchaseFailedNotification object:nil userInfo:nil];

    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"updated transaction called");
    for(SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}



- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
 
    NSLog(@"Transaction error: %@", error.localizedDescription);
    
    

}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"Restore Completed");
    if(self.numberOfRestoredTransactions == 0)
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoreCompleted object:nil userInfo:nil];
    else if(self.numberOfRestoredTransactions > 0)
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoreCompletedWithNumber object:[NSString stringWithFormat:@"%lu",(unsigned long)self.numberOfRestoredTransactions] userInfo:nil];

}





@end
