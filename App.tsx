import React, { useState, useEffect } from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  Platform,
} from 'react-native';
import TurboCalculator from './modules/turbo-calculator';
import TurboDeviceInfo from './modules/turbo-deviceinfo';
import ExpoStorage from './modules/expo-storage';
import ExpoLogger from './modules/expo-logger';

function App(): React.JSX.Element {
  const [calcResult, setCalcResult] = useState<string>('');
  const [deviceInfo, setDeviceInfo] = useState<string>('');
  const [storageResult, setStorageResult] = useState<string>('');
  const [logCount, setLogCount] = useState<number>(0);

  // Initialize log count from native on mount
  useEffect(() => {
    const initLogCount = async () => {
      try {
        const count = await ExpoLogger.getLogCount();
        setLogCount(count);
        console.log('📊 [App] Initialized log count from native:', count);
      } catch (error) {
        console.error('Failed to get initial log count:', error);
      }
    };
    initLogCount();
  }, []);

  const performCalculation = async () => {
    try {
      const result = TurboCalculator.add(10, 5);
      setCalcResult(`Result: ${result}`);
      
      // Wait a bit for native call to complete
      setTimeout(async () => {
        const count = await ExpoLogger.getLogCount();
        setLogCount(count);
      }, 100);
    } catch (error) {
      console.error('TurboCalculator error:', error);
      setCalcResult('Error: Module not found');
    }
  };

  const getDeviceInfo = async () => {
    try {
      const model = TurboDeviceInfo.getDeviceModel();
      setDeviceInfo(`Device: ${model}`);
    } catch (error) {
      console.error('TurboDeviceInfo error:', error);
      setDeviceInfo('Error: Module not found');
    }
  };

  const testStorage = async () => {
    try {
      await ExpoStorage.setItem('test-key', 'test-value');
      const value = await ExpoStorage.getItem('test-key');
      setStorageResult(`Retrieved: ${value}`);
    } catch (error) {
      console.error('ExpoStorage error:', error);
      setStorageResult('Error: Module not found');
    }
  };

  const testLogger = async () => {
    try {
      await ExpoLogger.logInfo('Test log message from UI');
      const count = await ExpoLogger.getLogCount();
      setLogCount(count);
    } catch (error) {
      console.error('ExpoLogger error:', error);
    }
  };

  const resetLogger = async () => {
    try {
      await ExpoLogger.resetLogCount();
      const count = await ExpoLogger.getLogCount();
      setLogCount(count);
    } catch (error) {
      console.error('ExpoLogger reset error:', error);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={styles.title}>New Arch POC</Text>
        <Text style={styles.subtitle}>Testing Expo ↔ Turbo Module Communication (Bridgeless)</Text>

        {/* TurboModule: Calculator */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Turbo Module: Calculator</Text>
          <TouchableOpacity style={styles.button} onPress={performCalculation}>
            <Text style={styles.buttonText}>Calculate 10 + 5</Text>
          </TouchableOpacity>
          {calcResult ? <Text style={styles.result}>{calcResult}</Text> : null}
          <Text style={styles.moduleInfo}>
            Pattern: TurboCalculator → ExpoLogger (increments log count)
          </Text>
          <Text style={styles.nativeCallSuccess}>
            ✅ Bridgeless: TurboModule calls Expo Module
          </Text>
        </View>

        {/* TurboModule: Device Info */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Turbo Module: Device Info</Text>
          <TouchableOpacity style={styles.button} onPress={getDeviceInfo}>
            <Text style={styles.buttonText}>Get Device Model</Text>
          </TouchableOpacity>
          {deviceInfo ? <Text style={styles.result}>{deviceInfo}</Text> : null}
          <Text style={styles.moduleInfo}>
            Pattern: Consumed by ExpoStorage
          </Text>
          <Text style={styles.nativeCallSuccess}>
            ✅ Bridgeless: Expo Module calls Turbo Module
          </Text>
        </View>

        {/* Expo Module: Storage */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Expo Module: Storage</Text>
          <TouchableOpacity style={styles.button} onPress={testStorage}>
            <Text style={styles.buttonText}>Store and Retrieve "test-value"</Text>
          </TouchableOpacity>
          {storageResult ? <Text style={styles.result}>{storageResult}</Text> : null}
          <Text style={styles.moduleInfo}>
            Pattern: ExpoStorage → TurboDeviceInfo (appends device model to stored value)
          </Text>
          <Text style={styles.nativeCallSuccess}>
            ✅ Bridgeless: Expo Module calls Turbo Module
          </Text>
        </View>

            {/* Expo Module: Logger */}
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Expo Module: Logger</Text>
              <TouchableOpacity style={styles.button} onPress={testLogger}>
                <Text style={styles.buttonText}>Log Message</Text>
              </TouchableOpacity>
              <TouchableOpacity style={[styles.button, styles.resetButton]} onPress={resetLogger}>
                <Text style={styles.buttonText}>Reset Count</Text>
              </TouchableOpacity>
              <Text style={styles.result}>Log Count: {logCount}</Text>
              <Text style={styles.moduleInfo}>
                Pattern: Logged from UI, also incremented by TurboCalculator
              </Text>
              <Text style={styles.nativeCallSuccess}>
                ✅ Bridgeless: Turbo Module writes to Expo Module's shared state
              </Text>
            </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 0,
    paddingBottom: 50
  },
  scrollContent: {
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
    color: '#333',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    marginBottom: 24,
    textAlign: 'center',
  },
  section: {
    backgroundColor: '#fff',
    borderRadius: 8,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
    color: '#333',
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 12,
    borderRadius: 6,
    alignItems: 'center',
    marginBottom: 8,
  },
  resetButton: {
    backgroundColor: '#FF3B30',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '500',
  },
  result: {
    marginTop: 8,
    fontSize: 16,
    color: '#333',
    fontWeight: '500',
  },
  moduleInfo: {
    marginTop: 8,
    fontSize: 12,
    color: '#666',
    fontStyle: 'italic',
  },
  nativeCallSuccess: {
    marginTop: 4,
    fontSize: 12,
    color: '#34C759',
    fontWeight: '600',
  },
});

export default App;
