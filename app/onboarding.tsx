import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  TouchableOpacity,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useTheme } from '../context/ThemeContext';
import { useLanguage } from '../context/LanguageContext';
import { LinearGradient } from 'expo-linear-gradient';

const { width } = Dimensions.get('window');

export default function OnboardingScreen() {
  const router = useRouter();
  const { isDark } = useTheme();
  const { t } = useLanguage();

  const handleGetStarted = () => {
    router.push('/location/country');
  };

  return (
    <View
      style={[styles.container, { backgroundColor: isDark ? '#000' : '#fff' }]}
    >
      <LinearGradient
        colors={isDark ? ['#1a1a1a', '#000'] : ['#fff', '#f5f5f5']}
        style={styles.gradient}
      >
        <View style={styles.content}>
          <Text style={[styles.title, { color: isDark ? '#fff' : '#000' }]}>
            {t('appName')}
          </Text>
          <Text style={[styles.subtitle, { color: isDark ? '#ccc' : '#666' }]}>
            {t('appDescription')}
          </Text>

          <TouchableOpacity
            style={[
              styles.button,
              { backgroundColor: isDark ? '#fff' : '#000' },
            ]}
            onPress={handleGetStarted}
          >
            <Text
              style={[styles.buttonText, { color: isDark ? '#000' : '#fff' }]}
            >
              {t('continue')}
            </Text>
          </TouchableOpacity>
        </View>
      </LinearGradient>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  gradient: {
    flex: 1,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 36,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 18,
    textAlign: 'center',
    marginBottom: 40,
  },
  loadingContainer: {
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
  },
  buttonContainer: {
    width: width * 0.8,
    gap: 12,
  },
  button: {
    paddingHorizontal: 32,
    paddingVertical: 16,
    borderRadius: 30,
    alignItems: 'center',
  },
  buttonText: {
    fontSize: 18,
    fontWeight: '600',
  },
  secondaryButton: {
    paddingHorizontal: 32,
    paddingVertical: 16,
    borderRadius: 30,
    alignItems: 'center',
    borderWidth: 1,
  },
  secondaryButtonText: {
    fontSize: 18,
    fontWeight: '600',
  },
});
