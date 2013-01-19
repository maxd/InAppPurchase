#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define IN_APP_PURCHASE_PRODUCTS_UPDATE_STARTED_NOTIFICATION @"InAppPurchaseProductsUpdateStarted"
#define IN_APP_PURCHASE_PRODUCTS_UPDATE_FINISHED_NOTIFICATION @"InAppPurchaseProductsUpdateFinished"

#define IN_APP_PURCHASE_PRODUCTS_UPDATE_SUCCESS_NOTIFICATION @"InAppPurchaseProductsUpdateSuccess"
#define IN_APP_PURCHASE_PRODUCTS_UPDATE_FAILED_NOTIFICATION @"InAppPurchaseProductsUpdateFailed"

#define IN_APP_PURCHASE_PAYMENT_SUCCESS_NOTIFICATION @"InAppPurchasePaymentSuccess"
#define IN_APP_PURCHASE_PAYMENT_FAIL_NOTIFICATION @"InAppPurchasePaymentFail"

#define IN_APP_PURCHASE_RESTORE_SUCCESS_NOTIFICATION @"InAppPurchaseRestoreSuccess"
#define IN_APP_PURCHASE_RESTORE_FAIL_NOTIFICATION @"InAppPurchaseRestoreFail"

#define IN_APP_PURCHASE_STARTED_NOTIFICATION @"InAppPurchaseStarted"
#define IN_APP_PURCHASE_FINISHED_NOTIFICATION @"InAppPurchaseFinished"

@protocol InAppPurchaseProductActivator;
@protocol InAppPurchaseAlertHandler;

@interface InAppPurchaseManager : NSObject

@property (strong) id<InAppPurchaseAlertHandler> alertHandler;

- (void)addProductActivator:(id<InAppPurchaseProductActivator>)productHandler;

- (void)removeProductActivator:(id<InAppPurchaseProductActivator>)productHandler;

- (void)updateProducts;

- (BOOL)canMakePurchases;

- (void)purchaseProduct:(NSString *)productIdentifier;

- (void)restorePurchases;

- (SKProduct *)productByIdentifier:(NSString *)productIdentifier;

@end
