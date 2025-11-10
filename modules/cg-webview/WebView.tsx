import React, { forwardRef, useEffect, type Ref } from 'react';
import { View, Text, ActivityIndicator, StyleSheet } from 'react-native';
import {
  WebView as RNWebView,
  type WebViewProps as RNWebViewProps,
} from 'react-native-webview';
import type { WebViewProps, WebViewManager } from './types';

// Note: For production, you'd use nativeConfig to wrap with custom view
// For POC, we just use standard RNWebView since WebViewIntegrations is the key part

// Stub components for POC
const RouteLoadingOverlay = () => (
  <View style={styles.overlay}>
    <ActivityIndicator size="small" color="#007AFF" />
  </View>
);

const ErrorScreen = ({ isLoading, onRecover }: { isLoading: boolean; onRecover?: () => void }) => (
  <View style={styles.errorContainer}>
    <Text style={styles.errorText}>{isLoading ? 'Recovering...' : 'Error loading WebView'}</Text>
    {onRecover && (
      <Text style={styles.retryText} onPress={onRecover}>
        Retry
      </Text>
    )}
  </View>
);

const LoadingScreen = () => (
  <View style={styles.loadingContainer}>
    <ActivityIndicator size="large" color="#007AFF" />
    <Text style={styles.loadingText}>Loading WebView...</Text>
  </View>
);

const Null = () => null;

export const WebView = forwardRef(function ForwardedWebView(
  { manager, injectedJavaScriptObject = {} }: WebViewProps,
  ref: Ref<RNWebView>
) {
  const {
    context: {
      webView: { status, initialUrl },
    },
  } = manager;

  useEffect(() => {
    console.log('🌐 [CGWebView] WebView opened', { initialUrl });
  }, [initialUrl]);

  return (
    <>
      {status === 'loading' ? <RouteLoadingOverlay /> : null}
      {(status === 'error' || status === 'recovering') && manager.onRecover ? (
        <ErrorScreen isLoading={status === 'recovering'} onRecover={manager.onRecover} />
      ) : null}
      <RNWebView
        allowsBackForwardNavigationGestures
        allowsInlineMediaPlayback
        autoManageStatusBarEnabled={false}
        geolocationEnabled
        sharedCookiesEnabled
        startInLoadingState
        ref={ref}
        decelerationRate="normal"
        mediaPlaybackRequiresUserAction
        originWhitelist={['http://*', 'https://*', 'tel:*', 'mailto:*', 'about:srcdoc*']}
        source={{ uri: initialUrl }}
        onLoadStart={manager.onLoadStart}
        onLoadProgress={manager.onLoadProgress}
        onLoad={manager.onLoad}
        onMessage={manager.onMessage}
        onContentProcessDidTerminate={manager.onContentProcessDidTerminate}
        onRenderProcessGone={manager.onRenderProcessGone}
        onNavigationStateChange={manager.onNavigationStateChange}
        onShouldStartLoadWithRequest={manager.onShouldStartLoadWithRequest}
        onError={manager.onError}
        renderError={() => <Null />}
        renderLoading={() => (status === 'initial' ? <LoadingScreen /> : <Null />)}
        style={styles.webview}
        injectedJavaScriptObject={injectedJavaScriptObject}
        setBuiltInZoomControls={false}
      />
    </>
  );
});

const styles = StyleSheet.create({
  webview: {
    marginTop: -1,
    opacity: 0.99,
  },
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.1)',
    zIndex: 1000,
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  errorText: {
    fontSize: 16,
    color: '#f00',
    marginBottom: 16,
  },
  retryText: {
    fontSize: 16,
    color: '#007AFF',
    textDecorationLine: 'underline',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#666',
  },
});

