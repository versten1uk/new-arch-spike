// Import from app-level specs (following official docs pattern)
import NativeCalculator from '../../specs/NativeTurboCalculator';

export const TurboCalculator = {
  add: (a: number, b: number): number => {
    if (!NativeCalculator) {
      console.warn('[TurboCalculator] Module not loaded, returning 0');
      return 0;
    }
    return NativeCalculator.add(a, b);
  },
  subtract: (a: number, b: number): number => {
    if (!NativeCalculator) {
      console.warn('[TurboCalculator] Module not loaded, returning 0');
      return 0;
    }
    return NativeCalculator.subtract(a, b);
  },
  multiply: (a: number, b: number): number => {
    if (!NativeCalculator) {
      console.warn('[TurboCalculator] Module not loaded, returning 0');
      return 0;
    }
    return NativeCalculator.multiply(a, b);
  },
  divide: (a: number, b: number): number => {
    if (!NativeCalculator) {
      console.warn('[TurboCalculator] Module not loaded, returning 0');
      return 0;
    }
    return NativeCalculator.divide(a, b);
  },
};

export default TurboCalculator;

