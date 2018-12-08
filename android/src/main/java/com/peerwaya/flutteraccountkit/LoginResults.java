package com.peerwaya.flutteraccountkit;

import com.facebook.accountkit.AccessToken;
import com.facebook.accountkit.Account;
import com.facebook.accountkit.AccountKitError;
import com.facebook.accountkit.AccountKitLoginResult;

import java.util.HashMap;
import java.util.Map;

public class LoginResults {
    static final Map<String, String> cancelledByUser = new HashMap<String, String>() {{
        put("status", "cancelledByUser");
    }};

    static Map<String, Object> success(AccountKitLoginResult loginResult) {
        final AccessToken accessToken = loginResult.getAccessToken();
        if (accessToken != null) {
            final Map<String, Object> accessTokenMap = LoginResults.accessToken(accessToken);
            final String state = loginResult.getFinalAuthorizationState();
            return new HashMap<String, Object>() {{
                put("state", state);
                put("status", "loggedIn");
                put("accessToken", accessTokenMap);
            }};
        } else {
            final String code = loginResult.getAuthorizationCode();
            final String state = loginResult.getFinalAuthorizationState();
            return new HashMap<String, Object>() {{
                put("status", "loggedIn");
                put("code", code);
                put("state", state);
            }};
        }
    }

    static Map<String, String> error(final AccountKitError error) {
        return new HashMap<String, String>() {{
            put("status", "error");
            put("errorMessage", error.getErrorType().getMessage());
        }};
    }

    static Map<String, Object> accessToken(final AccessToken accessToken) {
        if (accessToken == null) {
            return null;
        }

        return new HashMap<String, Object>() {{
            put("accountId", accessToken.getAccountId());
            put("appId", accessToken.getApplicationId());
            put("token", accessToken.getToken());
            put("lastRefresh", accessToken.getLastRefresh().getTime());
            put("refreshIntervalSeconds", accessToken.getTokenRefreshIntervalSeconds());
        }};
    }

    static Map<String, Object> account(final Account account) {
        if (account == null) {
            return null;
        }

        final HashMap<String, Object> map = new HashMap<String, Object>() {{
            put("accountId", account.getId());
            put("email", account.getEmail());
        }};

        if (account.getPhoneNumber() != null) {
            final HashMap<String, Object> phoneNumber = new HashMap<String, Object>() {{
                put("countryCode", account.getPhoneNumber().getCountryCode());
                put("number", account.getPhoneNumber().getPhoneNumber());
            }};
            map.put("phoneNumber", phoneNumber);
        }

        return map;
    }
}
