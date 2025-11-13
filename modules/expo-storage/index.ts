import { requireNativeModule } from 'expo-modules-core';
import { NativeModules } from 'react-native';

let ExpoStorageModule = null;
try {
  ExpoStorageModule = requireNativeModule('ExpoStorage');
} catch (e) {
  ExpoStorageModule = NativeModules.ExpoStorage;
}

if (!ExpoStorageModule) {
  // Provide stub implementation to prevent crashes
  ExpoStorageModule = {
    setItem: async () => {},
    getItem: async () => { return null; },
    removeItem: async () => {},
    getAllKeys: async () => { return []; },
  };
}

export default {
  setItem: async (key: string, value: string): Promise<void> => {
    return await ExpoStorageModule.setItem(key, value);
  },
  getItem: async (key: string): Promise<string | null> => {
    return await ExpoStorageModule.getItem(key);
  },
  removeItem: async (key: string): Promise<void> => {
    return await ExpoStorageModule.removeItem(key);
  },
  getAllKeys: async (): Promise<string[]> => {
    return await ExpoStorageModule.getAllKeys();
  },
};
