import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  TextInput,
  ActivityIndicator,
  SafeAreaView,
} from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { useTheme } from '../../context/ThemeContext';
import { Ionicons } from '@expo/vector-icons';
import { countries } from '../../constants/countries';
import { toTitleCaseUTF8 } from '../../utils/string';
import { useTranslation } from 'react-i18next';

interface City {
  SehirAdi: string;
  SehirAdiEn: string;
  SehirID: string;
}

interface RouteParams {
  country: string;
}

function getFlagEmoji(countryCode: string) {
  const codePoints = countryCode
    .toUpperCase()
    .split('')
    .map((char) => 127397 + char.charCodeAt(0));
  return String.fromCodePoint(...codePoints);
}

export default function CityScreen() {
  const route = useRoute();
  const navigation = useNavigation();
  const { country } = route.params as RouteParams;
  const { isDark } = useTheme();
  const [cities, setCities] = useState<City[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const { t } = useTranslation();

  const selectedCountry = countries.find((c) => c.id === country);

  useEffect(() => {
    fetchCities();
  }, [country]);

  const fetchCities = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetch(
        `https://ezanvakti.emushaf.net/sehirler/${country}`
      );
      if (!response.ok) {
        throw new Error('Failed to fetch cities');
      }
      const data = await response.json();
      setCities(data);
    } catch (err) {
      console.error(err);
      setError('Failed to load cities. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const filteredCities = cities.filter((city) =>
    city.SehirAdi.normalize('NFD')
      .toLowerCase()
      .includes(searchQuery.normalize('NFD').toLowerCase())
  );

  const handleCitySelect = (city: City) => {
    navigation.navigate('district', {
      city: city.SehirID,
      cityName: city.SehirAdi,
      countryCode: selectedCountry?.code,
    });
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
          onPress={fetchCities}
        >
          <Text style={[styles.retryText, { color: isDark ? '#fff' : '#000' }]}>
            {t('retry')}
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
            {t('selectCity')}
          </Text>
        </View>
        <Text style={[styles.subtitle, { color: isDark ? '#ccc' : '#666' }]}>
          {t('selectCitySub')}
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
          placeholder={t('searchCity')}
          placeholderTextColor={isDark ? '#666' : '#999'}
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </View>

      <FlatList
        data={filteredCities}
        keyExtractor={(item) => item.SehirID}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={[
              styles.cityItem,
              { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' },
            ]}
            onPress={() => handleCitySelect(item)}
          >
            <Text
              style={[styles.cityName, { color: isDark ? '#fff' : '#000' }]}
            >
              {toTitleCaseUTF8(item.SehirAdi)}
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
  cityItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 15,
    marginHorizontal: 20,
    borderRadius: 10,
  },
  cityName: {
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
