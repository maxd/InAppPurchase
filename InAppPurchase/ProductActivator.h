#import <Foundation/Foundation.h>

@class SKPaymentTransaction;

@protocol ProductActivator <NSObject>

@property (strong, readonly) NSString *productIdentifier;

- (BOOL)activateProduct:(SKPaymentTransaction *)transaction;

@end
