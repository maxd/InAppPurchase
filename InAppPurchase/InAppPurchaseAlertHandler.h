#import <Foundation/Foundation.h>

@protocol InAppPurchaseAlertHandler <NSObject>

- (void)showWarning:(NSString *)message;

- (void)showError:(NSString *)message;

@end
