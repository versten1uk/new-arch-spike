import { requireNativeModule } from 'expo-modules-core';
import { NativeModules } from 'react-native';

let ExpoLoggerModule = null;
try {
  ExpoLoggerModule = requireNativeModule('ExpoLogger');
} catch (e) {
  ExpoLoggerModule = NativeModules.ExpoLogger;
}

if (!ExpoLoggerModule) {
  // Provide stub implementation to prevent crashes
  ExpoLoggerModule = {
    logInfo: async () => {},
    logWarning: async () => {},
    logError: async () => {},
    getLogCount: async () => { return 0; },
    resetLogCount: async () => {},
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
