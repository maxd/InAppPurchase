#import <Foundation/Foundation.h>
#import "ProductActivator.h"

@interface UserDefaultsProductActivator : NSObject <ProductActivator>

- (id)initWithProductIdentifier:(NSString *)productIdentifier;

@end
