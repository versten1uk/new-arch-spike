import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  getDeviceModel(): string;
  getDeviceName(): string;
  getSystemVersion(): string;
  getBundleId(): string;
}

export default TurboModuleRegistry.getEnforcing<Spec>('TurboDeviceInfo');

