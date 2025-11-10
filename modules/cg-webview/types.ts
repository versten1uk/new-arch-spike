import type { WebViewProps as RNWebViewProps } from 'react-native-webview';

export interface WebViewManager {
  context: {
    webView: {
      status: 'initial' | 'loading' | 'loaded' | 'error' | 'recovering';
      initialUrl: string;
    };
  };
  onLoadStart?: RNWebViewProps['onLoadStart'];
  onLoadProgress?: RNWebViewProps['onLoadProgress'];
  onLoad?: RNWebViewProps['onLoad'];
  onMessage?: RNWebViewProps['onMessage'];
  onContentProcessDidTerminate?: RNWebViewProps['onContentProcessDidTerminate'];
  onRenderProcessGone?: RNWebViewProps['onRenderProcessGone'];
  onNavigationStateChange?: RNWebViewProps['onNavigationStateChange'];
  onShouldStartLoadWithRequest?: RNWebViewProps['onShouldStartLoadWithRequest'];
  onError?: RNWebViewProps['onError'];
  onRecover?: () => void;
}

export interface WebViewProps {
  manager: WebViewManager;
  injectedJavaScriptObject?: {
    isInWebViewModal?: boolean;
    mobileAppTrackingData?: {
      metadata?: {
        resultSetId?: string | null;
      };
    };
  };
}

