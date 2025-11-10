import NativeDeviceInfo from './src/NativeTurboDeviceInfo';

export const TurboDeviceInfo = {
  getDeviceName: (): string => {
    if (!NativeDeviceInfo) {
      console.warn('[TurboDeviceInfo] Module not loaded, returning empty string');
      return '';
    }
    return NativeDeviceInfo.getDeviceName();
  },
  getSystemVersion: (): string => {
    if (!NativeDeviceInfo) {
      console.warn('[TurboDeviceInfo] Module not loaded, returning empty string');
      return '';
    }
    return NativeDeviceInfo.getSystemVersion();
  },
  getBundleId: (): string => {
    if (!NativeDeviceInfo) {
      console.warn('[TurboDeviceInfo] Module not loaded, returning empty string');
      return '';
    }
    return NativeDeviceInfo.getBundleId();
  },
  getDeviceModel: (): string => {
    if (!NativeDeviceInfo) {
      console.warn('[TurboDeviceInfo] Module not loaded, returning empty string');
      return '';
    }
    return NativeDeviceInfo.getDeviceModel();
  },
};

export default TurboDeviceInfo;

