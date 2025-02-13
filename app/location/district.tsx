import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  FlatList,
  TextInput,
  ActivityIndicator,
  SafeAreaView,
} from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { useTheme } from '../../context/ThemeContext';
import { useLocation } from '../../context/LocationContext';
import { usePrayerTimes } from '../../context/PrayerTimesContext';
import { Ionicons } from '@expo/vector-icons';
import { countries } from '../../constants/countries';
import { toTitleCaseUTF8 } from '../../utils/string';
import { useTranslation } from 'react-i18next';

interface District {
  IlceAdi: string;
  IlceAdiEn: string;
  IlceID: string;
}

interface RouteParams {
  city: string;
  cityName: string;
  countryCode: string;
}

function getFlagEmoji(countryCode: string) {
  const codePoints = countryCode
    .toUpperCase()
    .split('')
    .map((char) => 127397 + char.charCodeAt(0));
  return String.fromCodePoint(...codePoints);
}

export default function DistrictScreen() {
  const route = useRoute();
  const navigation = useNavigation();
  const { city, cityName, countryCode } = route.params as RouteParams;
  const { isDark } = useTheme();
  const { setLocation } = useLocation();
  const { fetchPrayerTimes } = usePrayerTimes();
  const [districts, setDistricts] = useState<District[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const { t } = useTranslation();

  const selectedCountry = countries.find(
    (c) => c.code.toLowerCase() === countryCode?.toString().toLowerCase()
  );

  useEffect(() => {
    fetchDistricts();
  }, [city]);

  const fetchDistricts = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetch(
        `https://ezanvakti.emushaf.net/ilceler/${city}`
      );
      if (!response.ok) {
        throw new Error('Failed to fetch districts');
      }
      const data = await response.json();
      setDistricts(data);
    } catch (err) {
      console.error(err);
      setError('Failed to load districts. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const filteredDistricts = districts.filter((district) =>
    district.IlceAdi.normalize('NFD')
      .toLowerCase()
      .includes(searchQuery.normalize('NFD').toLowerCase())
  );

  const handleDistrictSelect = async (district: District) => {
    if (selectedCountry) {
      setLocation({
        country: {
          id: selectedCountry.id,
          name: selectedCountry.name,
          code: selectedCountry.code,
        },
        city: {
          id: city?.toString() || '',
          name: cityName?.toString() || '',
        },
        district: {
          id: district.IlceID,
          name: district.IlceAdi,
        },
      });

      // Fetch prayer times for the selected district
      await fetchPrayerTimes(district.IlceID);

      navigation.navigate('dashboard');
    }
  };

  if (loading) {
    return (
      <SafeAreaView
        style={[
          styles.container,
          styles.centered,
          { backgroundColor: isDark ? '#000' : '#fff' },
        ]}
      >
        <ActivityIndicator size="large" color={isDark ? '#fff' : '#000'} />
      </SafeAreaView>
    );
  }

  if (error) {
    return (
      <SafeAreaView
        style={[
          styles.container,
          styles.centered,
          { backgroundColor: isDark ? '#000' : '#fff' },
        ]}
      >
        <Text
          style={[styles.errorText, { color: isDark ? '#ff6b6b' : '#dc3545' }]}
        >
          {error}
        </Text>
        <TouchableOpacity
          style={[
            styles.retryButton,
            { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' },
          ]}
          onPress={fetchDistricts}
        >
          <Text style={[styles.retryText, { color: isDark ? '#fff' : '#000' }]}>
            Retry
          </Text>
        </TouchableOpacity>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView
      style={[styles.container, { backgroundColor: isDark ? '#000' : '#fff' }]}
    >
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Ionicons
            name="chevron-back"
            size={24}
            color={isDark ? '#fff' : '#000'}
          />
        </TouchableOpacity>
        <View style={styles.titleContainer}>
          {selectedCountry && (
            <Text style={styles.flag}>
              {getFlagEmoji(selectedCountry.code)}
            </Text>
          )}
          <Text style={[styles.title, { color: isDark ? '#fff' : '#000' }]}>
            {toTitleCaseUTF8(cityName?.toString() || '')}
          </Text>
        </View>
        <Text style={[styles.subtitle, { color: isDark ? '#ccc' : '#666' }]}>
          {t('selectDistrictSub')}
        </Text>
      </View>

      <View
        style={[
          styles.searchContainer,
          { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' },
        ]}
      >
        <Ionicons name="search" size={20} color={isDark ? '#ccc' : '#666'} />
        <TextInput
          style={[styles.searchInput, { color: isDark ? '#fff' : '#000' }]}
          placeholder={t('searchDistrict')}
          placeholderTextColor={isDark ? '#666' : '#999'}
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </View>

      <FlatList
        data={filteredDistricts}
        keyExtractor={(item) => item.IlceID}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={[
              styles.districtItem,
              { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' },
            ]}
            onPress={() => handleDistrictSelect(item)}
          >
            <Text
              style={[styles.districtName, { color: isDark ? '#fff' : '#000' }]}
            >
              {toTitleCaseUTF8(item.IlceAdi)}
            </Text>
            <Ionicons
              name="chevron-forward"
              size={20}
              color={isDark ? '#666' : '#999'}
            />
          </TouchableOpacity>
        )}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
      />

      <View style={styles.footer}>
        <Text style={[styles.disclaimer, { color: isDark ? '#ccc' : '#666' }]}>
          {t('diyanetWarning')}
        </Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  centered: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  header: {
    padding: 20,
  },
  backButton: {
    marginBottom: 16,
  },
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  flag: {
    fontSize: 24,
    marginRight: 12,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
  },
  subtitle: {
    fontSize: 16,
    marginBottom: 20,
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    margin: 20,
    padding: 10,
    borderRadius: 10,
  },
  searchInput: {
    flex: 1,
    marginLeft: 10,
    fontSize: 16,
  },
  districtItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 15,
    marginHorizontal: 20,
    borderRadius: 10,
  },
  districtName: {
    flex: 1,
    fontSize: 16,
    fontWeight: '500',
  },
  separator: {
    height: 10,
  },
  errorText: {
    fontSize: 16,
    marginBottom: 20,
    textAlign: 'center',
  },
  retryButton: {
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 8,
  },
  retryText: {
    fontSize: 16,
    fontWeight: '500',
  },
  footer: {
    padding: 20,
    paddingBottom: 40,
  },
  disclaimer: {
    fontSize: 12,
    textAlign: 'center',
    fontStyle: 'italic',
  },
});
