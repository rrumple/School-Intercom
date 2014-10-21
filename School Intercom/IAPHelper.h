//
//  IAPHelper.h
//  School Intercom
//
//  Created by Randall Rumple on 5/3/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
UIKIT_EXTERN NSString * const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString * const IAPHelperProductPurchaseFailedNotification;
UIKIT_EXTERN NSString * const IAPHelperProductRestoredPurchaseNotification;
UIKIT_EXTERN NSString * const IAPHelperProductRestoreCompleted;
UIKIT_EXTERN NSString * const IAPHelperProductRestoreCompletedWithNumber;



typedef void (^RequestProdecutsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProdecutsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;


@end
