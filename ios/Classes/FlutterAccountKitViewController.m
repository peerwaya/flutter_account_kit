//
//  AccountKitViewController.m
//  Runner
//
//  Created by Onyemaechi Okafor on 19/07/2018.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

#import "FlutterAccountKitPlugin.h"

@implementation FlutterAccountKitViewController
{
    FlutterAccountKitViewController *_instance;
    
    AKFAccountKit *_accountKit;
    UIViewController<AKFViewController> *_pendingLoginViewController;
    NSString *_authorizationCode;
    BOOL *isUserLoggedIn;
    
    FlutterResult _result;
}

- (instancetype)initWithAccountKit:(AKFAccountKit *)accountKit
{
    self = [super init];
    _accountKit = accountKit;
    
    _pendingLoginViewController = [_accountKit viewControllerForLoginResume];
    _instance = self;
    
    return self;
}

- (void)_prepareLoginViewController:(UIViewController<AKFViewController> *)viewController
{
    viewController.delegate = self;
    if(self.theme != nil) {
        viewController.theme = self.theme;
    }
    if (self.countryWhitelist != nil) {
        viewController.whitelistedCountryCodes = self.countryWhitelist;
    }
    if (self.countryBlacklist != nil) {
        viewController.blacklistedCountryCodes = self.countryBlacklist;
    }
    viewController.defaultCountryCode = self.defaultCountry;
    
}

- (void)loginWithPhone: (FlutterResult)result
{
    _result = result;
    NSString *prefillPhone = self.initialPhoneNumber;
    NSString *prefillCountryCode = self.initialPhoneCountryPrefix;
    NSString *inputState = [[NSUUID UUID] UUIDString];
    AKFPhoneNumber * prefillPhoneNumber = [[AKFPhoneNumber alloc] initWithCountryCode:prefillCountryCode phoneNumber:prefillPhone];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController<AKFViewController> *viewController = [_accountKit viewControllerForPhoneLoginWithPhoneNumber:prefillPhoneNumber state:inputState];
        [self _prepareLoginViewController:viewController];
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        [rootViewController presentViewController:viewController animated:YES completion:NULL];
    });
}

- (void)loginWithEmail: (FlutterResult)result;
{
    _result = result;
    NSString *prefillEmail = self.initialEmail;
    NSString *inputState = [[NSUUID UUID] UUIDString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController<AKFViewController> *viewController = [_accountKit viewControllerForEmailLoginWithEmail:prefillEmail state:inputState];
        [self _prepareLoginViewController:viewController];
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        [rootViewController presentViewController:viewController animated:YES completion:NULL];
    });
}

- (void)viewController:(UIViewController<AKFViewController> *)viewController
didCompleteLoginWithAccessToken:(id<AKFAccessToken>)accessToken
                 state:(NSString *)state
{
    if (_result) {
        _result(@{
                  @"status" : @"loggedIn",
                  @"accessToken" : [FlutterAccountKitPlugin formatAccessToken: accessToken]
                  });
    }
}

- (void)viewController:(UIViewController<AKFViewController> *)viewController
didCompleteLoginWithAuthorizationCode:(NSString *)code
                 state:(NSString *)state
{
    if (_result) {
        _result(@{
                  @"status" : @"loggedIn",
                  @"code" : code,
                  });
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // TODO: analyse if this needs to be implemented here or could be handled in React side
}

- (void)viewController:(UIViewController<AKFViewController> *)viewController didFailWithError:(NSError *)error
{
     if (_result) {
         _result(@{
                  @"status" : @"error",
                  @"errorMessage" : [error description],
                  });
     }
}

- (void)viewControllerDidCancel:(UIViewController<AKFViewController> *)viewController
{
    if (_result) {
        _result(@{
                 @"status" : @"cancelledByUser",
                 });
    }
}

@end
