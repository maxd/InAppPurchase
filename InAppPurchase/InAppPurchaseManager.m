#import <StoreKit/StoreKit.h>
#import "InAppPurchaseManager.h"
#import "InAppPurchaseProductActivator.h"
#import "InAppPurchaseAlertHandler.h"

@interface InAppPurchaseManager () <SKPaymentTransactionObserver, SKProductsRequestDelegate> {
    NSMutableArray *productActivators;

    SKProductsRequest *productsRequest;

    NSArray *products;
}

@end

@implementation InAppPurchaseManager

@synthesize alertHandler = _alertHandler;

- (id)initWithAlertHandler:(id<InAppPurchaseAlertHandler>)alertHandler {
    self = [super init];
    if (self) {
        productActivators = [NSMutableArray new];

        _alertHandler = alertHandler;

        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)addProductActivator:(id <InAppPurchaseProductActivator>)productActivator {
    [productActivators addObject:productActivator];
}

- (void)removeProductActivator:(id <InAppPurchaseProductActivator>)productActivator {
    [productActivators removeObject:productActivator];
}

- (void)updateProducts {
    NSMutableSet *productIdentifiers = [NSMutableSet new];

    for (id<InAppPurchaseProductActivator> purchaseActivator in productActivators) {
        [productIdentifiers addObject:purchaseActivator.productIdentifier];
    }

    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];

    [[NSNotificationCenter defaultCenter]
            postNotificationName:IN_APP_PURCHASE_PRODUCTS_UPDATE_STARTED_NOTIFICATION
                          object:nil];
}

- (BOOL)canMakePurchases {
    return [SKPaymentQueue canMakePayments];
}

- (SKProduct *)productByIdentifier:(NSString *)productIdentifier {
    NSArray *result = [products filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productIdentifier == %@", productIdentifier]];
    return result.count ? [result objectAtIndex:0] : nil;
}

- (void)purchaseProduct:(NSString *)productIdentifier {
    SKProduct *product = [self productByIdentifier:productIdentifier];

    if (product) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];

        [[SKPaymentQueue defaultQueue] addPayment:payment];

        [[NSNotificationCenter defaultCenter]
                postNotificationName:IN_APP_PURCHASE_STARTED_NOTIFICATION
                              object:nil];
    } else {
        NSLog(@"[InAppPurchase] %@ Can't find product identifier in updated products. Possible updateProducts method isn't called.", productIdentifier);
        [_alertHandler showError:L(@"product-not-found")];
    }
}

- (void)restorePurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];

    [[NSNotificationCenter defaultCenter]
            postNotificationName:IN_APP_PURCHASE_STARTED_NOTIFICATION
                          object:nil];
}

#pragma mark SKRequest Handlers

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    products = response.products;

    if (response.invalidProductIdentifiers.count != 0) {
        NSLog(@"[InAppPurchase] - Some products has unknown or invalid product identifiers: ");
        for (NSString *productIdentifier in response.invalidProductIdentifiers) {
            NSLog(@"[InAppPurchase] -  * %@", productIdentifier);
        }

        [_alertHandler showWarning:L(@"invalid-products")];
    }

    [[NSNotificationCenter defaultCenter]
            postNotificationName:IN_APP_PURCHASE_PRODUCTS_UPDATE_SUCCESS_NOTIFICATION
                          object:nil];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"[InAppPurchase] - Can't update products from iTunesConnect: %@", error);
    [_alertHandler showError:[NSString stringWithFormat:L(@"product-list-unavailable"), error.localizedDescription]];

    [[NSNotificationCenter defaultCenter]
            postNotificationName:IN_APP_PURCHASE_PRODUCTS_UPDATE_FAILED_NOTIFICATION
                          object:nil];
}

- (void)requestDidFinish:(SKRequest *)request {
    [[NSNotificationCenter defaultCenter]
            postNotificationName:IN_APP_PURCHASE_PRODUCTS_UPDATE_FINISHED_NOTIFICATION
                          object:nil];
}

#pragma mark SKPaymentQueue Handlers

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
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

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    BOOL result = [self provideContent:transaction withProductIdentifier:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:result];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    BOOL result = [self provideContent:transaction withProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:result];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    [self finishTransaction:transaction wasSuccessful:NO];
}

- (id <InAppPurchaseProductActivator>)productActivatorByProductIdentifier:(NSString *)productIdentifier {
    NSArray *result = [productActivators filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productIdentifier == %@", productIdentifier]];
    return result.count ? [result objectAtIndex:0] : nil;
}

- (BOOL)provideContent:(SKPaymentTransaction *)transaction withProductIdentifier:(NSString *)productIdentifier {
    BOOL result = NO;

    id <InAppPurchaseProductActivator> productActivator = [self productActivatorByProductIdentifier:productIdentifier];

    if (productActivator) {
        BOOL productActivatorResult = [productActivator activateProduct:transaction];

        if (productActivatorResult) {
            result = YES;
        } else {
            NSLog(@"[InAppPurchase] %@ Can't activate purchased product.", productIdentifier);
            [_alertHandler showError:L(@"can-not-activate-product")];
        }
    } else {
        NSLog(@"[InAppPurchase] %@ Can't find product activator.", productIdentifier);
        [_alertHandler showError:L(@"product-activator-not-found")];
    }

    return result;
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful {
    if (wasSuccessful) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

        [[NSNotificationCenter defaultCenter]
                postNotificationName:IN_APP_PURCHASE_PAYMENT_SUCCESS_NOTIFICATION
                              object:nil];

    } else {
        NSString *productIdentifier = transaction.payment.productIdentifier;

        switch (transaction.error.code) {
            case SKErrorUnknown:
                NSLog(@"[InAppPurchase] %@ Unknown error: %@", productIdentifier, transaction.error);
                [_alertHandler showError:[NSString stringWithFormat:@"%@.", transaction.error.localizedDescription]];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKErrorClientInvalid:       // client is not allowed to issue the request, etc.
                NSLog(@"[InAppPurchase] %@ Client is not allowed to perform purchase request.", productIdentifier);
                [_alertHandler showError:L(@"client-invalid-error")];
                break;
            case SKErrorPaymentCancelled:    // user cancelled the request, etc.
                NSLog(@"[InAppPurchase] %@ Purchase canceled.", productIdentifier);
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKErrorPaymentInvalid:      // purchase identifier was invalid, etc.
                NSLog(@"[InAppPurchase] %@ Purchase identifier was invalid.", productIdentifier);
                [_alertHandler showError:L(@"payment-invalid-error")];
                break;
            case SKErrorPaymentNotAllowed:   // this device is not allowed to make the payment
                NSLog(@"[InAppPurchase] %@ This device is not allowed to make the payment.", productIdentifier);
                [_alertHandler showError:L(@"payment-not-allowed-error")];
                break;
            default:
                NSLog(@"[InAppPurchase] %@ Unknown error code. Error: %@", productIdentifier, transaction.error);
                [_alertHandler showError:[NSString stringWithFormat:@"%@.", transaction.error.localizedDescription]];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }

        [[NSNotificationCenter defaultCenter]
                postNotificationName:IN_APP_PURCHASE_PAYMENT_FAIL_NOTIFICATION
                              object:nil];
    }

    [[NSNotificationCenter defaultCenter]
            postNotificationName:IN_APP_PURCHASE_FINISHED_NOTIFICATION
                          object:nil];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    [[NSNotificationCenter defaultCenter]
            postNotificationName:IN_APP_PURCHASE_RESTORE_SUCCESS_NOTIFICATION
                          object:nil];

    [[NSNotificationCenter defaultCenter]
            postNotificationName:IN_APP_PURCHASE_FINISHED_NOTIFICATION
                          object:nil];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter]
            postNotificationName:IN_APP_PURCHASE_RESTORE_FAIL_NOTIFICATION
                          object:nil];

    [[NSNotificationCenter defaultCenter]
            postNotificationName:IN_APP_PURCHASE_FINISHED_NOTIFICATION
                          object:nil];
}

@end
