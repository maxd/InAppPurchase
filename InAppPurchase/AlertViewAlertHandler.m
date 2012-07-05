#import "AlertViewAlertHandler.h"
#import <UIKit/UIKit.h>

@implementation AlertViewAlertHandler

- (void)showWarning:(NSString *)message {
    [self showAlert:message withTitle:@"Предупреждение"];
}

- (void)showError:(NSString *)message {
    [self showAlert:message withTitle:@"Ошибка"];
}

- (void)showAlert:(NSString *)message withTitle:(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle:title
                  message:message
                 delegate:nil
        cancelButtonTitle:@"Закрыть"
        otherButtonTitles:nil];

    [alertView show];
}

@end
