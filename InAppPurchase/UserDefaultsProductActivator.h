#import <Foundation/Foundation.h>
#import "InAppPurchaseProductActivator.h"

@interface UserDefaultsProductActivator : NSObject <InAppPurchaseProductActivator>

- (id)initWithProductIdentifier:(NSString *)productIdentifier;

@end
