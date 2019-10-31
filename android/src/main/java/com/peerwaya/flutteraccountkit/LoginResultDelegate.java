package com.peerwaya.flutteraccountkit;

import android.content.Intent;

import com.facebook.accountkit.AccountKitLoginResult;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

class LoginResultDelegate implements PluginRegistry.ActivityResultListener {
    private static final String ERROR_LOGIN_IN_PROGRESS = "login_in_progress";

    private MethodChannel.Result pendingResult;


    void setPendingResult(String methodName, MethodChannel.Result result) {
        if (pendingResult != null) {
            result.error(
                    ERROR_LOGIN_IN_PROGRESS,
                    methodName + " called while another Facebook " +
                            "login operation was in progress.",
                    null
            );
        }

        pendingResult = result;
    }


    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == FlutterAccountKitPlugin.APP_REQUEST_CODE) {
            if (RESULT_OK != resultCode) {
                finishWithResult(LoginResults.cancelledByUser);
                return true;
            }
            
            AccountKitLoginResult loginResult = data.getParcelableExtra(AccountKitLoginResult.RESULT_KEY);
            if (loginResult.getError() != null) {
                finishWithResult(LoginResults.error(loginResult.getError()));
            } else if (loginResult.wasCancelled()) {
                finishWithResult(LoginResults.cancelledByUser);
            } else {
                finishWithResult(LoginResults.success(loginResult));
            }
            return true;
        }
        return false;
    }

    private void finishWithResult(Object result) {
        if (pendingResult != null) {
            pendingResult.success(result);
            pendingResult = null;
        }
    }
}
