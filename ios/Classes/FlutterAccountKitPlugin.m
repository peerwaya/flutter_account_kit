//
//  AccountKit.m
//  Runner
//
//  Created by Onyemaechi Okafor on 19/07/2018.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

#import "FlutterAccountKitPlugin.h"

@implementation FlutterAccountKitPlugin {
    AKFAccountKit *_accountKit;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
                                     methodChannelWithName:@"com.peerwaya/flutter_account_kit"
                                     binaryMessenger:[registrar messenger]];
    FlutterAccountKitPlugin *instance = [[FlutterAccountKitPlugin alloc] init];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
    if ([@"configure" isEqualToString:call.method]) {
        NSDictionary *options = call.arguments[@"configOptions"];

        [self configureWithOptions:options
                            result:result];
    } else if ([@"login" isEqualToString:call.method]) {
        AKFLoginType loginType =
        [self loginTypeFromString:call.arguments[@"loginType"]];
        [self loginWithType:loginType
                     result:result];
    } else if ([@"logOut" isEqualToString:call.method]) {
        [self logOut:result];
    } else if ([@"getCurrentAccessToken" isEqualToString:call.method]) {
        [self getCurrentAccessToken:result];
    } else if ([@"getCurrentAccount" isEqualToString:call.method]) {
        [self getCurrentAccount:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)configureWithOptions:(NSDictionary *)options
               result:(FlutterResult)result {
    self.options = options;
    result(nil);
}

- (void)loginWithType:(AKFLoginType)type
               result:(FlutterResult)result {
    @try {
        FlutterAccountKitViewController* a = [[FlutterAccountKitViewController alloc] initWithAccountKit: [self getAccountKit]];
        a.theme = [self getTheme];
        a.countryWhitelist = [self.options valueForKey:@"countryWhitelist"];
        a.countryBlacklist = [self.options valueForKey:@"countryBlacklist"];
        a.defaultCountry = [self.options valueForKey:@"defaultCountry"];
        a.initialEmail = [self.options valueForKey:@"initialEmail"];
        a.initialPhoneCountryPrefix = [self.options valueForKey:@"initialPhoneCountryPrefix"];
        a.initialPhoneNumber = [self.options valueForKey:@"initialPhoneNumber"];
        if (type == AKFLoginTypePhone) {
            [a loginWithPhone: result];
        } else {
            [a loginWithEmail: result];
        }
    }
    @catch (NSException * e) {
        result([FlutterError errorWithCode:@"login_failed"
                                   message:@"Could not login"
                                   details:[FlutterAccountKitPlugin errorFromException:e]]);
    }
}

- (AKFLoginType)loginTypeFromString:(NSString *)loginTypeStr {
    if ([@"email" isEqualToString:loginTypeStr]) {
        return AKFLoginTypeEmail;
    } else if ([@"phone" isEqualToString:loginTypeStr]) {
        return AKFLoginTypePhone;
    } else {
        NSString *message = [NSString
                             stringWithFormat:@"Unknown login type: %@", loginTypeStr];

        @throw [NSException exceptionWithName:@"InvalidLoginTypeException"
                                       reason:message
                                     userInfo:nil];
    }
}

- (void)getCurrentAccessToken:(FlutterResult)result {
    @try {
        id<AKFAccessToken> accessToken = [[self getAccountKit] currentAccessToken];

        if (![accessToken accountID]) {
            return result(nil);
        }

        result([FlutterAccountKitPlugin formatAccessToken:accessToken]);
    }
    @catch (NSException * e) {
        result([FlutterError errorWithCode:@"access_token_error"
                                   message:@"Could not get access token"
                                   details:[FlutterAccountKitPlugin errorFromException:e]]);
    }
}

- (void)getCurrentAccount:(FlutterResult)result {
    __block bool callbackCalled = false;
    [[self getAccountKit] requestAccount:^(id<AKFAccount> account, NSError *error) {
        if (callbackCalled) {
            return;
        }
        callbackCalled = true;

        if (error) {
            result([FlutterError errorWithCode:@"request_account"
                                       message:@"Could not get account data"
                                       details:error]);
        } else {
            result([FlutterAccountKitPlugin formatAccountData:account]);
        }
    }];
}

- (AKFTheme *)getTheme {
    AKFTheme *theme = [AKFTheme defaultTheme];
    NSDictionary *themeOptions = [self.options objectForKey:@"theme"];
    if(themeOptions == nil) {
        return theme;
    }
    NSArray *colorOptions = @[@"backgroundColor",
                              @"headerBackgroundColor",@"headerTextColor",@"headerButtonTextColor",
                              @"buttonBackgroundColor",@"buttonBorderColor",@"buttonTextColor",
                              @"buttonDisabledBackgroundColor",@"buttonDisabledBorderColor",
                              @"buttonDisabledTextColor",@"iconColor",@"inputBackgroundColor",
                              @"inputBorderColor",@"inputTextColor",@"textColor",@"titleColor"];
    for(NSString *key in themeOptions) {
        UIColor *color;
        if([colorOptions containsObject:key]) {
            NSDictionary *value = [themeOptions valueForKey:key];
            color = [UIColor colorWithRed:[[value valueForKey:@"r"] floatValue]
                                    green:[[value valueForKey:@"g"] floatValue]
                                     blue:[[value valueForKey:@"b"] floatValue]
                                    alpha:[[value valueForKey:@"a"] floatValue]];
            [theme setValue:color forKey:key];
        } else if([key isEqualToString:@"backgroundImage"]) {
            theme.backgroundImage = [UIImage imageNamed:[themeOptions objectForKey:key]];
        } else if([key isEqualToString:@"statusBarStyle"]) {
            int statusBarStyle = ((NSNumber*)[themeOptions valueForKey:key]).intValue;
            if (UIStatusBarStyleDefault == statusBarStyle) {
                theme.statusBarStyle = UIStatusBarStyleDefault;
            }
            if (UIStatusBarStyleLightContent == statusBarStyle) {
                theme.statusBarStyle = UIStatusBarStyleLightContent;
            }
        }
    }
    return theme;
}

- (void)logOut:(FlutterResult)result {
    @try {
        [[self getAccountKit] logOut];
        result(nil);
    }
    @catch (NSException * e) {
        result([FlutterError errorWithCode:@"logout_error"
                                   message:@"Could not logout"
                                   details:[FlutterAccountKitPlugin errorFromException:e]]);
    }
}

- (AKFAccountKit*) getAccountKit
{
    if (_accountKit == nil) {
        // may also specify AKFResponseTypeAccessToken
        BOOL useAccessToken = [[self.options valueForKey:@"responseType"] isEqualToString:@"token"];
        AKFResponseType responseType = useAccessToken ? AKFResponseTypeAccessToken : AKFResponseTypeAuthorizationCode;
        _accountKit = [[AKFAccountKit alloc] initWithResponseType:responseType];
    }

    return _accountKit;
}

+ (NSMutableDictionary*) formatAccountData: (id<AKFAccount>) account
{
    NSMutableDictionary *result =[[NSMutableDictionary alloc] init];
    result[@"id"] = account.accountID;
    result[@"email"] = account.emailAddress;

    if (account.phoneNumber && account.phoneNumber.phoneNumber) {
        result[@"phoneNumber"] = @{
                                   @"number": account.phoneNumber.phoneNumber,
                                   @"countryCode": account.phoneNumber.countryCode
                                   };
    }

    return result;
}

+ (NSMutableDictionary*) formatAccessToken: (id<AKFAccessToken>) accessToken
{
    NSMutableDictionary *accessTokenData =[[NSMutableDictionary alloc] init];
    accessTokenData[@"accountId"] = [accessToken accountID];
    accessTokenData[@"appId"] = [accessToken applicationID];
    accessTokenData[@"token"] = [accessToken tokenString];
    accessTokenData[@"lastRefresh"] = [NSNumber numberWithLong: ([[accessToken lastRefresh] timeIntervalSince1970] * 1000)];
    accessTokenData[@"refreshIntervalSeconds"] = [NSNumber numberWithLong: [accessToken tokenRefreshInterval]];


    return accessTokenData;
}

+ (NSError *) errorFromException: (NSException *) exception
{
    NSDictionary *exceptionInfo = @{
                                    @"name": exception.name,
                                    @"reason": exception.reason,
                                    @"callStackReturnAddresses": exception.callStackReturnAddresses,
                                    @"callStackSymbols": exception.callStackSymbols,
                                    @"userInfo": exception.userInfo
                                    };

    return [[NSError alloc] initWithDomain: @"FlutterAccountKit"
                                      code: 0
                                  userInfo: exceptionInfo];
}
@end
