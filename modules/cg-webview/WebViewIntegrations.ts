import { NativeModules } from 'react-native';

interface WebViewIntegrationsInterface {
  // Pattern 1: WebViewIntegrations → ExpoLogger (like Firebase Analytics)
  getLoggerCount(): Promise<number>;
  
  // Pattern 2: WebViewIntegrations → TurboCalculator (TurboModule → TurboModule)
  performCalculation(a: number, b: number): Promise<number>;
  
  // Pattern 3: WebViewIntegrations → CustomDeviceInfo (get device info)
  getDeviceModel(): string;
  
  // Pattern 4: WebViewIntegrations → ExpoLogger (like AppsFlyer tracking)
  logEvent(eventName: string): void;
}

const { WebViewIntegrations } = NativeModules;

if (!WebViewIntegrations) {
  console.error('[WebViewIntegrations] Native module not found!');
}

export default WebViewIntegrations as WebViewIntegrationsInterface;

