import { requireNativeModule } from 'expo-modules-core';
import { NativeModules } from 'react-native';

let ExpoLoggerModule = null;
try {
  ExpoLoggerModule = requireNativeModule('ExpoLogger');
} catch (e) {
  console.log('[ExpoLogger] requireNativeModule failed, trying NativeModules:', e);
  ExpoLoggerModule = NativeModules.ExpoLogger;
}

if (!ExpoLoggerModule) {
  console.error('[ExpoLogger] Module not found! Available modules:', Object.keys(NativeModules));
  
  // Provide stub implementation to prevent crashes
  ExpoLoggerModule = {
    logInfo: async () => { console.log('[ExpoLogger] Stub - module not loaded'); },
    logWarning: async () => { console.warn('[ExpoLogger] Stub - module not loaded'); },
    logError: async () => { console.error('[ExpoLogger] Stub - module not loaded'); },
    getLogCount: async () => { return 0; },
    resetLogCount: async () => { console.log('[ExpoLogger] Stub - reset not available'); },
  };
}

export default {
  logInfo: async (message: string): Promise<void> => {
    return await ExpoLoggerModule.logInfo(message);
  },
  logWarning: async (message: string): Promise<void> => {
    return await ExpoLoggerModule.logWarning(message);
  },
  logError: async (message: string): Promise<void> => {
    return await ExpoLoggerModule.logError(message);
  },
  getLogCount: async (): Promise<number> => {
    return await ExpoLoggerModule.getLogCount();
  },
  resetLogCount: async (): Promise<void> => {
    return await ExpoLoggerModule.resetLogCount();
  },
};
