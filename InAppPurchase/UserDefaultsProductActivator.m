#import "UserDefaultsProductActivator.h"

@interface UserDefaultsProductActivator () {
    NSString *productIdentifier;
}

@end

@implementation UserDefaultsProductActivator

- (id)initWithProductIdentifier:(NSString *)_productIdentifier {
    self = [super init];
    if (self) {
        productIdentifier = _productIdentifier;
    }
    return self;
}

- (NSString *)productIdentifier {
    return productIdentifier;
}

- (BOOL)activateProduct:(SKPaymentTransaction *)transaction {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];

    return YES;
}

@end
