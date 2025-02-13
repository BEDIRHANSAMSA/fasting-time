import { View, Text, StyleSheet, TouchableOpacity, Switch } from 'react-native';
import { useTheme } from '../context/ThemeContext';
import { useLocation } from '../context/LocationContext';
import { useLanguage } from '../context/LanguageContext';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { toTitleCaseUTF8, getFlagEmoji } from '../utils/string';

export default function SettingsScreen() {
  const { isDark, setTheme } = useTheme();
  const { location, clearLocation } = useLocation();
  const { language, setLanguage, t } = useLanguage();
  const router = useRouter();

  const toggleTheme = () => {
    setTheme(isDark ? 'light' : 'dark');
  };

  const handleChangeLocation = () => {
    clearLocation();
    router.replace('/onboarding');
  };

  return (
    <View style={[styles.container, { backgroundColor: isDark ? '#000' : '#fff' }]}>
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => router.back()}
        >
          <Ionicons 
            name="chevron-back" 
            size={24} 
            color={isDark ? '#fff' : '#000'} 
          />
        </TouchableOpacity>
        <Text style={[styles.headerTitle, { color: isDark ? '#fff' : '#000' }]}>
          {t('settings')}
        </Text>
      </View>

      <View style={styles.content}>
        <View style={[styles.card, { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' }]}>
          <Text style={[styles.sectionTitle, { color: isDark ? '#fff' : '#000' }]}>
            {t('language')}
          </Text>
          
          <TouchableOpacity
            style={[
              styles.languageButton,
              { backgroundColor: language === 'tr' ? (isDark ? '#333' : '#e5e5e5') : 'transparent' }
            ]}
            onPress={() => setLanguage('tr')}
          >
            <Text style={[styles.languageText, { color: isDark ? '#fff' : '#000' }]}>
              {t('turkish')}
            </Text>
            {language === 'tr' && (
              <Ionicons name="checkmark" size={20} color={isDark ? '#fff' : '#000'} />
            )}
          </TouchableOpacity>

          <TouchableOpacity
            style={[
              styles.languageButton,
              { backgroundColor: language === 'en' ? (isDark ? '#333' : '#e5e5e5') : 'transparent' }
            ]}
            onPress={() => setLanguage('en')}
          >
            <Text style={[styles.languageText, { color: isDark ? '#fff' : '#000' }]}>
              {t('english')}
            </Text>
            {language === 'en' && (
              <Ionicons name="checkmark" size={20} color={isDark ? '#fff' : '#000'} />
            )}
          </TouchableOpacity>
        </View>

        <View style={[styles.card, { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' }]}>
          <Text style={[styles.sectionTitle, { color: isDark ? '#fff' : '#000' }]}>
            {t('location')}
          </Text>
          
          {location && (
            <View style={styles.locationInfo}>
              <View style={styles.locationHeader}>
                <Text style={styles.flag}>
                  {getFlagEmoji(location.country.code)}
                </Text>
                <View>
                  <Text style={[styles.locationText, { color: isDark ? '#fff' : '#000' }]}>
                    {location.country.name}
                  </Text>
                  <Text style={[styles.locationSubtext, { color: isDark ? '#ccc' : '#666' }]}>
                    {toTitleCaseUTF8(location.city.name)}, {toTitleCaseUTF8(location.district.name)}
                  </Text>
                </View>
              </View>
            </View>
          )}

          <TouchableOpacity
            style={[styles.button, { backgroundColor: isDark ? '#333' : '#e5e5e5' }]}
            onPress={handleChangeLocation}
          >
            <Ionicons 
              name="location-outline" 
              size={20} 
              color={isDark ? '#fff' : '#000'} 
              style={styles.buttonIcon} 
            />
            <Text style={[styles.buttonText, { color: isDark ? '#fff' : '#000' }]}>
              {t('changeLocation')}
            </Text>
          </TouchableOpacity>
        </View>

        <View style={[styles.card, { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' }]}>
          <Text style={[styles.sectionTitle, { color: isDark ? '#fff' : '#000' }]}>
            {t('appearance')}
          </Text>
          
          <View style={styles.settingRow}>
            <View style={styles.settingLabelContainer}>
              <Ionicons 
                name="moon-outline" 
                size={20} 
                color={isDark ? '#fff' : '#000'} 
                style={styles.settingIcon} 
              />
              <Text style={[styles.settingLabel, { color: isDark ? '#fff' : '#000' }]}>
                {t('darkMode')}
              </Text>
            </View>
            <Switch
              value={isDark}
              onValueChange={toggleTheme}
              trackColor={{ false: '#767577', true: '#81b0ff' }}
              thumbColor={isDark ? '#f5dd4b' : '#f4f3f4'}
            />
          </View>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    paddingTop: 60,
    paddingHorizontal: 20,
    paddingBottom: 20,
    flexDirection: 'row',
    alignItems: 'center',
  },
  backButton: {
    marginRight: 16,
  },
  headerTitle: {
    fontSize: 32,
    fontWeight: 'bold',
  },
  content: {
    flex: 1,
    padding: 20,
    gap: 20,
  },
  card: {
    padding: 20,
    borderRadius: 16,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 16,
  },
  languageButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
  },
  languageText: {
    fontSize: 16,
    fontWeight: '500',
  },
  locationInfo: {
    marginBottom: 16,
  },
  locationHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  flag: {
    fontSize: 24,
    marginRight: 12,
  },
  locationText: {
    fontSize: 16,
    fontWeight: '500',
  },
  locationSubtext: {
    fontSize: 14,
    marginTop: 2,
  },
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 12,
    borderRadius: 8,
  },
  buttonIcon: {
    marginRight: 8,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '500',
  },
  settingRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  settingLabelContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  settingIcon: {
    marginRight: 12,
  },
  settingLabel: {
    fontSize: 16,
    fontWeight: '500',
  },
});