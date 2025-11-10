import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  getDeviceName(): string;
  getSystemVersion(): string;
  getBundleId(): string;
  getDeviceModel(): string;
}

export default TurboModuleRegistry.getEnforcing<Spec>('CustomDeviceInfo');

