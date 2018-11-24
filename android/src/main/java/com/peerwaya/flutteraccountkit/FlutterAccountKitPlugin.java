package com.peerwaya.flutteraccountkit;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.facebook.accountkit.AccessToken;
import com.facebook.accountkit.Account;
import com.facebook.accountkit.AccountKit;
import com.facebook.accountkit.AccountKitCallback;
import com.facebook.accountkit.AccountKitError;
import com.facebook.accountkit.PhoneNumber;
import com.facebook.accountkit.ui.AccountKitActivity;
import com.facebook.accountkit.ui.AccountKitConfiguration;
import com.facebook.accountkit.ui.LoginType;

/**
 * FlutterAccountKitPlugin
 */
public class FlutterAccountKitPlugin implements MethodCallHandler {
    public static final String CHANNEL_NAME = "com.peerwaya/flutter_account_kit";
    private static final String METHOD_LOG_IN = "login";
    private static final String METHOD_LOG_OUT = "logOut";
    private static final String METHOD_GET_CURRENT_ACCESS_TOKEN = "getCurrentAccessToken";
    private static final String METHOD_GET_CURRENT_ACCOUNT = "getCurrentAccount";
    private static final String METHOD_CONFIGURE = "configure";
    private static final String ARG_LOGIN_TYPE = "loginType";
    private static final String ARG_CONFIG_OPTIONS = "configOptions";
    public static int APP_REQUEST_CODE = 99;
    public static String LOG_TAG = "FlutterAccountKit";
    private final AccountKitDelegate delegate;

    private FlutterAccountKitPlugin(Registrar registrar) {
        delegate = new AccountKitDelegate(registrar);
    }

    public static void registerWith(Registrar registrar) {
        final FlutterAccountKitPlugin plugin = new FlutterAccountKitPlugin(registrar);
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(plugin);
        AccountKit.initialize(registrar.context(), null);
    }

    //  Replace Turkish İ and ı with their normalized versions (I and i, respectively)
    private static String safeString(String str) {
        return str.replace("İ", "I").replace("ı", "i");
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case METHOD_CONFIGURE:
                Map options = call.argument(ARG_CONFIG_OPTIONS);
                delegate.configure(options, result);
                break;
            case METHOD_LOG_IN:
                String loginTypeStr = call.argument(ARG_LOGIN_TYPE);
                LoginType loginType = LoginType.valueOf(safeString(loginTypeStr.toUpperCase()));
                delegate.logIn(loginType, result);
                break;
            case METHOD_LOG_OUT:
                delegate.logOut(result);
                break;
            case METHOD_GET_CURRENT_ACCESS_TOKEN:
                delegate.getCurrentAccessToken(result);
                break;
            case METHOD_GET_CURRENT_ACCOUNT:
                delegate.getCurrentAccount(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    public static final class AccountKitDelegate {
        private final Registrar registrar;
        private final LoginResultDelegate resultDelegate;
        private Map options;

        public AccountKitDelegate(Registrar registrar) {
            this.registrar = registrar;
            this.resultDelegate = new LoginResultDelegate();
            registrar.addActivityResultListener(resultDelegate);
        }

        public void configure(
                Map options, Result result) {
            this.options = options;
            result.success(null);
        }


        public void logIn(
                LoginType loginType, Result result) {
            if (!AccountKit.isInitialized()) {
                Log.w(LOG_TAG, "AccountKit not initialized yet. `login` call discarded");
                result.success(null);
                return;
            }

            if (this.options == null) {
                Log.e(LOG_TAG, "You must call `configure` method providing configure options first");
                result.success(null);
                return;
            }
            final String method = METHOD_LOG_IN;
            this.resultDelegate.setPendingResult(method, result);

            final Intent intent = new Intent(this.registrar.context(), AccountKitActivity.class);
            final AccountKitConfiguration.AccountKitConfigurationBuilder configurationBuilder =
                    createAccountKitConfiguration(loginType);
            intent.putExtra(AccountKitActivity.ACCOUNT_KIT_ACTIVITY_CONFIGURATION, configurationBuilder.build());
            this.registrar.activity().startActivityForResult(intent, APP_REQUEST_CODE, new Bundle());
        }

        public void logOut(Result result) {
            if (!AccountKit.isInitialized()) {
                Log.w(LOG_TAG, "AccountKit not initialized yet. `logout` call discarded");
                result.success(null);
                return;
            }

            AccountKit.logOut();
            result.success(null);
        }

        public void getCurrentAccessToken(Result result) {
            if (!AccountKit.isInitialized()) {
                Log.w(LOG_TAG, "AccountKit not initialized yet. `getCurrentAccessToken` call discarded");
                result.success(null);
                return;
            }

            AccessToken token = AccountKit.getCurrentAccessToken();

            Map<String, Object> tokenMap = LoginResults.accessToken(token);

            result.success(tokenMap);
        }

        public void getCurrentAccount(final Result result) {
            if (!AccountKit.isInitialized()) {
                Log.w(LOG_TAG, "AccountKit not initialized yet. `getCurrentAccount` call discarded");
                result.success(null);
                return;
            }

            AccountKit.getCurrentAccount(new AccountKitCallback<Account>() {
                @Override
                public void onSuccess(Account account) {
                    result.success(LoginResults.account(account));
                }

                @Override
                public void onError(AccountKitError error) {
                    result.success(null);
                }
            });
        }

        /**
         * Private methods
         */

        private AccountKitConfiguration.AccountKitConfigurationBuilder createAccountKitConfiguration(
                final LoginType loginType) {
            AccountKitConfiguration.AccountKitConfigurationBuilder configurationBuilder =
                    new AccountKitConfiguration.AccountKitConfigurationBuilder(loginType,
                            AccountKitActivity.ResponseType.valueOf(
                                    safeString(((String) this.options.get("responseType")).toUpperCase())));

            String initialAuthState = (String) this.options.get(("initialAuthState"));
            if (initialAuthState != null && !initialAuthState.isEmpty()) {
                configurationBuilder.setInitialAuthState(initialAuthState);
            }

            String initialEmail = (String) this.options.get("initialEmail");
            if (initialEmail != null && !initialEmail.isEmpty()) {
                configurationBuilder.setInitialEmail(initialEmail);
            }

            String initialPhoneCountryPrefix = (String) this.options.get("initialPhoneCountryPrefix");
            String initialPhoneNumber = (String) this.options.get("initialPhoneNumber");

            if (initialPhoneCountryPrefix != null && initialPhoneNumber != null) {
                PhoneNumber phoneNumber = new PhoneNumber(initialPhoneCountryPrefix, initialPhoneNumber, null);
                configurationBuilder.setInitialPhoneNumber(phoneNumber);
            }

            configurationBuilder.setFacebookNotificationsEnabled(
                    (Boolean) this.options.get("facebookNotificationsEnabled"));

            boolean readPhoneStateEnabled = (Boolean) this.options.get("readPhoneStateEnabled");
            if (readPhoneStateEnabled && PackageManager.PERMISSION_DENIED == ContextCompat.checkSelfPermission(
                    this.registrar.context(), Manifest.permission.READ_PHONE_STATE)) {
                Log.w(LOG_TAG, "To allow reading phone number add READ_PHONE_STATE permission in your app's manifest");
                configurationBuilder.setReadPhoneStateEnabled(false);
            } else {
                configurationBuilder.setReadPhoneStateEnabled(readPhoneStateEnabled);
            }

            boolean receiveSMS = (Boolean) this.options.get("receiveSMS");
            if (receiveSMS && PackageManager.PERMISSION_DENIED == ContextCompat.checkSelfPermission(
                    this.registrar.context(), Manifest.permission.RECEIVE_SMS)) {
                Log.w(LOG_TAG, "To allow extracting code from SMS add RECEIVE_SMS permission in your app's manifest");
                configurationBuilder.setReceiveSMS(false);
            } else {
                configurationBuilder.setReceiveSMS(receiveSMS);
            }

            if (this.options.containsKey("countryBlacklist")) {
                String[] blacklist = formatCountryList((List<String>) this.options.get("countryBlacklist"));
                configurationBuilder.setSMSBlacklist(blacklist);
            }

            if (this.options.containsKey("countryWhitelist")) {
                String[] whitelist = formatCountryList((List<String>) this.options.get("countryWhitelist"));
                configurationBuilder.setSMSWhitelist(whitelist);
            }

            if (this.options.containsKey("defaultCountry")) {
                configurationBuilder.setDefaultCountryCode((String) this.options.get("defaultCountry"));
            }

            return configurationBuilder;
        }

        private String[] formatCountryList(List<String> list) {
            List<String> pre = new ArrayList<>();
            for (int i = 0, n = list.size(); i < n; i++) {
                pre.add(list.get(i));
            }

            String[] out = new String[pre.size()];
            return pre.toArray(out);
        }

    }
}
