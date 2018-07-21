#import <Flutter/Flutter.h>
#import "FlutterAccountKitViewController.h"

@interface FlutterAccountKitPlugin : NSObject<FlutterPlugin>

@property NSDictionary *options;
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar ;
+ (NSMutableDictionary*) formatAccessToken: (id<AKFAccessToken>) accessToken;
+ (NSMutableDictionary*) formatAccountData: (id<AKFAccount>) account;
@end
