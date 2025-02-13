import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  TextInput,
  Platform,
  Alert,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useTheme } from '../../context/ThemeContext';
import { useLanguage } from '../../context/LanguageContext';
import { Ionicons } from '@expo/vector-icons';
import { countries } from '../../constants/countries';
import { getFlagEmoji } from '../../utils/string';
import * as Location from 'expo-location';
import { useLocation } from '../../context/LocationContext';
import { usePrayerTimes } from '../../context/PrayerTimesContext';
import { City, District } from '@/types/api';
import { useRouter } from 'expo-router';

export default function CountryScreen() {
  const router = useRouter();

  const [detectingLocation, setDetectingLocation] = useState(false);
  const { setLocation } = useLocation();
  const { fetchPrayerTimes } = usePrayerTimes();

  const navigation = useNavigation();
  const { isDark } = useTheme();
  const { t } = useLanguage();
  const [searchQuery, setSearchQuery] = useState('');

  const filteredCountries = countries.filter((country) =>
    country.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleAutoDetectLocation = async () => {
    try {
      setDetectingLocation(true);

      // Request location permission
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        return;
      }

      // Get current location
      const location = await Location.getCurrentPositionAsync({});

      // Get the address details from coordinates
      const [addressInfo] = await Location.reverseGeocodeAsync({
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
      });

      if (!addressInfo || !addressInfo.city || !addressInfo.region) {
        throw new Error('Could not determine location');
      }

      // First, get cities in Turkey (since our API is Turkey-specific)
      const turkeyId = '2'; // Turkey's ID in our countries list
      const citiesResponse = await fetch(
        `https://ezanvakti.emushaf.net/sehirler/${turkeyId}`
      );
      const cities: City[] = await citiesResponse.json();

      // Find the matching city
      const detectedCity = addressInfo.region.toLowerCase();
      const city = cities.find(
        (c) =>
          c.SehirAdi.toLowerCase().includes(detectedCity) ||
          c.SehirAdiEn.toLowerCase().includes(detectedCity)
      );

      if (!city) {
        throw new Error('City not found');
      }

      // Get districts for the matched city
      const districtsResponse = await fetch(
        `https://ezanvakti.emushaf.net/ilceler/${city.SehirID}`
      );
      const districts: District[] = await districtsResponse.json();

      // Find the matching district
      const detectedDistrict = addressInfo.subregion?.toLowerCase() || '';
      let district = districts.find(
        (d) =>
          d.IlceAdi.toLowerCase().includes(detectedDistrict) ||
          d.IlceAdiEn.toLowerCase().includes(detectedDistrict)
      );

      if (!district) {
        district = districts.find(
          (d) =>
            d.IlceAdi.toLowerCase().includes(detectedCity) ||
            d.IlceAdiEn.toLowerCase().includes(detectedCity)
        );
      }

      const handleLocationConfirmed = async (selectedDistrict: District) => {
        // Update location context
        await setLocation({
          country: {
            id: '2', // Turkey
            name: 'Türkiye',
            code: 'TR',
          },
          city: {
            id: city.SehirID,
            name: city.SehirAdi,
          },
          district: {
            id: selectedDistrict.IlceID,
            name: selectedDistrict.IlceAdi,
          },
        });

        // Fetch prayer times
        await fetchPrayerTimes(selectedDistrict.IlceID);

        // Navigate to dashboard
        router.replace('/dashboard');
      };

      if (!district) {
        var message = t('locationConfirmCityMessage').replace(
          '{city}',
          city.SehirAdi
        );

        Alert.alert(t('locationDetected'), message, [
          {
            text: t('no'),
            style: 'cancel',
          },
          {
            text: t('yes'),
            onPress: () => {
              router.push({
                pathname: '/location/district',
                params: {
                  city: city.SehirID,
                  cityName: city.SehirAdi,
                  countryCode: 'TR',
                  autoDetected: 'true',
                },
              });
            },
          },
        ]);
        return;
      } else {
        var message = t('locationConfirmMessage')
          .replace('{district}', district.IlceAdi)
          .replace('{city}', city.SehirAdi);

        // Ask user to confirm the detected location
        Alert.alert(t('locationDetected'), message, [
          {
            text: t('no'),
            style: 'cancel',
          },
          {
            text: t('yes'),
            onPress: () => handleLocationConfirmed(district),
          },
        ]);
      }
    } catch (error) {
      console.error('Error detecting location:', error);
      Alert.alert(t('locationError'), t('locationErrorMessage'), [
        { text: t('ok') },
      ]);
    } finally {
      setDetectingLocation(false);
    }
  };

  useEffect(() => {
    // Auto-detect location when component mounts
    if (Platform.OS !== 'web') {
      // Skip auto-detection on web
      handleAutoDetectLocation();
    }
  }, []);

  const handleCountrySelect = (country: (typeof countries)[0]) => {
    navigation.navigate('city', { country: country.id });
  };

  return (
    <View
      style={[styles.container, { backgroundColor: isDark ? '#000' : '#fff' }]}
    >
      <View style={styles.header}>
        <Text style={[styles.title, { color: isDark ? '#fff' : '#000' }]}>
          🌍 {t('selectCountry')}
        </Text>
        <Text style={[styles.subtitle, { color: isDark ? '#ccc' : '#666' }]}>
          {t('selectCountrySub')}
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
          placeholder={t('searchCountry')}
          placeholderTextColor={isDark ? '#666' : '#999'}
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </View>

      <FlatList
        data={filteredCountries}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={[
              styles.countryItem,
              { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' },
            ]}
            onPress={() => handleCountrySelect(item)}
          >
            <View style={styles.flagContainer}>
              <Text style={styles.flag}>{getFlagEmoji(item.code)}</Text>
            </View>
            <Text
              style={[styles.countryName, { color: isDark ? '#fff' : '#000' }]}
            >
              {item.name}
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
          Uygulamadaki tüm vakit bilgileri, Diyanet İşleri Başkanlığı tarafından
          sağlanan resmi verilere dayanmaktadır
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 60,
  },
  header: {
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 8,
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
  countryItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 15,
    marginHorizontal: 20,
    borderRadius: 10,
  },
  flagContainer: {
    marginRight: 15,
  },
  flag: {
    fontSize: 24,
  },
  countryName: {
    flex: 1,
    fontSize: 16,
    fontWeight: '500',
  },
  separator: {
    height: 10,
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
