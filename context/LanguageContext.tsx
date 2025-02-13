import React, { createContext, useContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Platform, NativeModules } from 'react-native';
import translations from '../constants/translations';

export type Language = 'tr' | 'en';
type TranslationKey = keyof typeof translations.tr;

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: (key: TranslationKey) => string;
}

const LanguageContext = createContext<LanguageContextType | undefined>(
  undefined
);

function getDeviceLanguage(): Language {
  let deviceLanguage = 'en';

  if (Platform.OS === 'ios') {
    deviceLanguage =
      NativeModules.SettingsManager.settings.AppleLocale ||
      NativeModules.SettingsManager.settings.AppleLanguages[0];
  } else if (Platform.OS === 'android') {
    deviceLanguage = NativeModules.I18nManager.localeIdentifier;
  } else if (Platform.OS === 'web') {
    deviceLanguage = navigator.language;
  }

  return deviceLanguage.toLowerCase().startsWith('tr') ? 'tr' : 'en';
}

export function LanguageProvider({ children }: { children: React.ReactNode }) {
  const [language, setLanguageState] = useState<Language>('en');

  useEffect(() => {
    loadLanguage();
  }, []);

  const loadLanguage = async () => {
    try {
      const savedLanguage = await AsyncStorage.getItem('language');
      if (savedLanguage) {
        setLanguageState(savedLanguage as Language);
      } else {
        const deviceLang = getDeviceLanguage();
        setLanguageState(deviceLang);
        await AsyncStorage.setItem('language', deviceLang);
      }
    } catch (error) {
      console.error('Error loading language:', error);
    }
  };

  const setLanguage = async (newLanguage: Language) => {
    try {
      await AsyncStorage.setItem('language', newLanguage);
      setLanguageState(newLanguage);
    } catch (error) {
      console.error('Error saving language:', error);
    }
  };

  const t = (key: TranslationKey): string => {
    return translations[language][key] || translations.en[key] || key;
  };

  return (
    <LanguageContext.Provider value={{ language, setLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
}
