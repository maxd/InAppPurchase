#import "AlertViewAlertHandler.h"
#import <UIKit/UIKit.h>

@implementation AlertViewAlertHandler

- (void)showWarning:(NSString *)message {
    [self showAlert:message withTitle:L(@"warning-alert-title")];
}

- (void)showError:(NSString *)message {
    [self showAlert:message withTitle:L(@"error-alert-title")];
}

- (void)showAlert:(NSString *)message withTitle:(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle:title
                  message:message
                 delegate:nil
        cancelButtonTitle:L(@"close")
        otherButtonTitles:nil];

    [alertView show];
}

@end
