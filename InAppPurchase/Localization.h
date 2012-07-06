#import <Foundation/Foundation.h>

#define LC(key, comment) NSLocalizedStringFromTableInBundle(key, nil, [Localization frameworkBundle], comment)
#define L(key) LC(key, nil)

@interface Localization : NSObject

+ (NSBundle *)frameworkBundle;

@end
