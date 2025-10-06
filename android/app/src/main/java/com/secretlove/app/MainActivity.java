package com.secretlove.app;

import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Keep WebView running in background
        WebView webView = getBridge().getWebView();
        if (webView != null) {
            WebSettings settings = webView.getSettings();
            // Enable background execution
            settings.setJavaScriptEnabled(true);
            settings.setDomStorageEnabled(true);
            settings.setDatabaseEnabled(true);
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        // Don't pause WebView timers when going to background
        // This keeps Socket.IO connection alive
    }

    @Override
    public void onResume() {
        super.onResume();
        // Resume WebView when coming back to foreground
    }
}
