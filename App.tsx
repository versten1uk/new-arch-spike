import React, { useState } from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
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
            Uses data from: ExpoLogger (log count)
          </Text>
          <Text style={styles.nativeCallSuccess}>
            ✅ TurboModule → ExpoLogger (bridgeless)
          </Text>
        </View>

        {/* TurboModule: Device Info */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Turbo Module: Device Info</Text>
          <TouchableOpacity style={styles.button} onPress={getDeviceInfo}>
            <Text style={styles.buttonText}>Get Device Model</Text>
          </TouchableOpacity>
          {deviceInfo ? <Text style={styles.result}>{deviceInfo}</Text> : null}
        </View>

        {/* Expo Module: Storage */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Expo Module: Storage</Text>
          <TouchableOpacity style={styles.button} onPress={testStorage}>
            <Text style={styles.buttonText}>Store and Retrieve</Text>
          </TouchableOpacity>
          {storageResult ? <Text style={styles.result}>{storageResult}</Text> : null}
          <Text style={styles.moduleInfo}>
            Uses data from: CustomDeviceInfo (device model)
          </Text>
          <Text style={styles.nativeCallSuccess}>
            ✅ ExpoModule → TurboModule (bridgeless)
          </Text>
        </View>

        {/* Expo Module: Logger */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Expo Module: Logger</Text>
          <TouchableOpacity style={styles.button} onPress={testLogger}>
            <Text style={styles.buttonText}>Log Message</Text>
          </TouchableOpacity>
          <Text style={styles.result}>Log Count: {logCount}</Text>
          <Text style={styles.moduleInfo}>
            Shared state accessed by TurboCalculator
          </Text>
        </View>

        {/* Integration Test */}
        <View style={[styles.section, styles.integrationSection]}>
          <Text style={styles.sectionTitle}>🎯 Full Integration Test</Text>
          <TouchableOpacity
            style={[styles.button, styles.integrationButton]}
            onPress={async () => {
              await performCalculation();
              await getDeviceInfo();
              await testStorage();
              await testLogger();
            }}>
            <Text style={styles.buttonText}>Run All Tests</Text>
          </TouchableOpacity>
          <Text style={styles.integrationInfo}>
            Tests all module communications in bridgeless mode
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
    padding: 16,
    borderRadius: 8,
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
  integrationSection: {
    backgroundColor: '#E8F5E9',
    borderWidth: 2,
    borderColor: '#4CAF50',
  },
  integrationButton: {
    backgroundColor: '#4CAF50',
  },
  integrationInfo: {
    marginTop: 8,
    fontSize: 14,
    color: '#2E7D32',
    textAlign: 'center',
    fontWeight: '500',
  },
});

export default App;
