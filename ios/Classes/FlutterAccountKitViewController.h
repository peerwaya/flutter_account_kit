#import <UIKit/UIKit.h>
#import <AccountKit/AccountKit.h>


@interface FlutterAccountKitViewController : UIViewController<AKFViewControllerDelegate>

@property(nonatomic, strong) FlutterAccountKitViewController *instance;
@property(nonatomic, strong) AKFTheme *theme;
@property(nonatomic, strong) NSArray<NSString *> *countryWhitelist;
@property(nonatomic, strong) NSArray<NSString *> *countryBlacklist;
@property(nonatomic, strong) NSString *defaultCountry;
@property(nonatomic, strong) NSString *initialEmail;
@property(nonatomic, strong) NSString *initialPhoneNumber;
@property(nonatomic, strong) NSString *initialPhoneCountryPrefix;

- (instancetype) initWithAccountKit: (AKFAccountKit *)accountKit;

- (void)loginWithPhone: (FlutterResult)result;

- (void)loginWithEmail: (FlutterResult)result;

@end
