#import <Foundation/Foundation.h>

@class SKPaymentTransaction;

@protocol InAppPurchaseProductActivator <NSObject>

@property (strong, readonly) NSString *productIdentifier;

- (BOOL)activateProduct:(SKPaymentTransaction *)transaction;

@end
