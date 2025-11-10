import { requireNativeModule } from 'expo-modules-core';
import { NativeModules } from 'react-native';

let ExpoStorageModule = null;
try {
  ExpoStorageModule = requireNativeModule('ExpoStorage');
} catch (e) {
  console.log('[ExpoStorage] requireNativeModule failed, trying NativeModules:', e);
  ExpoStorageModule = NativeModules.ExpoStorage;
}

if (!ExpoStorageModule) {
  const availableModules = Object.keys(NativeModules);
  console.error('[ExpoStorage] Module not found!');
  console.error('[ExpoStorage] Total modules available:', availableModules.length);
  console.error('[ExpoStorage] Available modules:', JSON.stringify(availableModules, null, 2));
  
  // Provide stub implementation to prevent crashes
  ExpoStorageModule = {
    setItem: async () => { console.warn('[ExpoStorage] Module not loaded'); },
    getItem: async () => { console.warn('[ExpoStorage] Module not loaded'); return null; },
    removeItem: async () => { console.warn('[ExpoStorage] Module not loaded'); },
    getAllKeys: async () => { console.warn('[ExpoStorage] Module not loaded'); return []; },
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
