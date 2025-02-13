import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native';
import { useRouter, Redirect } from 'expo-router';
import { useTheme } from '../context/ThemeContext';
import { useLocation } from '../context/LocationContext';
import { usePrayerTimes } from '../context/PrayerTimesContext';
import { Ionicons } from '@expo/vector-icons';
import { toTitleCaseUTF8 } from '../utils/string';

function getFlagEmoji(countryCode: string) {
  const codePoints = countryCode
    .toUpperCase()
    .split('')
    .map((char) => 127397 + char.charCodeAt(0));
  return String.fromCodePoint(...codePoints);
}

export default function DashboardScreen() {
  const { isDark } = useTheme();
  const { location } = useLocation();
  const { prayerTimes, loading, error } = usePrayerTimes();
  const router = useRouter();

  if (!location) {
    return <Redirect href="/onboarding" />;
  }

  const today = new Date().toISOString().split('T')[0];
  const todaysPrayers = prayerTimes?.find(
    (time) => time.MiladiTarihUzunIso8601.split('T')[0] === today
  );

  console.log(today);

  console.log(todaysPrayers);

  return (
    <View
      style={[styles.container, { backgroundColor: isDark ? '#000' : '#fff' }]}
    >
      <View style={styles.header}>
        <Text style={[styles.headerTitle, { color: isDark ? '#fff' : '#000' }]}>
          Dashboard
        </Text>
        <TouchableOpacity
          style={styles.settingsButton}
          onPress={() => router.push('/settings')}
        >
          <Ionicons
            name="settings-outline"
            size={24}
            color={isDark ? '#fff' : '#000'}
          />
        </TouchableOpacity>
      </View>

      <View style={styles.content}>
        <View
          style={[
            styles.card,
            { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' },
          ]}
        >
          <View style={styles.locationHeader}>
            <Text style={styles.flag}>
              {getFlagEmoji(location.country.code)}
            </Text>
            <View>
              <Text
                style={[
                  styles.locationTitle,
                  { color: isDark ? '#fff' : '#000' },
                ]}
              >
                {toTitleCaseUTF8(location.district.name)}
              </Text>
              <Text
                style={[
                  styles.locationSubtitle,
                  { color: isDark ? '#ccc' : '#666' },
                ]}
              >
                {toTitleCaseUTF8(location.city.name)}, {location.country.name}
              </Text>
            </View>
          </View>
        </View>

        {loading ? (
          <View
            style={[
              styles.card,
              styles.centered,
              { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' },
            ]}
          >
            <ActivityIndicator size="large" color={isDark ? '#fff' : '#000'} />
          </View>
        ) : error ? (
          <View
            style={[
              styles.card,
              { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' },
            ]}
          >
            <Text
              style={[
                styles.errorText,
                { color: isDark ? '#ff6b6b' : '#dc3545' },
              ]}
            >
              {error}
            </Text>
          </View>
        ) : todaysPrayers ? (
          <View
            style={[
              styles.card,
              { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' },
            ]}
          >
            <View style={styles.prayerHeader}>
              <Text
                style={[styles.prayerDate, { color: isDark ? '#fff' : '#000' }]}
              >
                {todaysPrayers.MiladiTarihUzun}
              </Text>
              <Text
                style={[styles.hijriDate, { color: isDark ? '#ccc' : '#666' }]}
              >
                {todaysPrayers.HicriTarihUzun}
              </Text>
            </View>

            <View style={styles.prayerTimesGrid}>
              <View style={styles.prayerTimeItem}>
                <View
                  style={[
                    styles.prayerTimeCard,
                    { backgroundColor: isDark ? '#333' : '#fff' },
                  ]}
                >
                  <Ionicons
                    name="sunny-outline"
                    size={24}
                    color={isDark ? '#fff' : '#000'}
                  />
                  <Text
                    style={[
                      styles.prayerName,
                      { color: isDark ? '#fff' : '#000' },
                    ]}
                  >
                    İmsak
                  </Text>
                  <Text
                    style={[
                      styles.prayerTime,
                      { color: isDark ? '#fff' : '#000' },
                    ]}
                  >
                    {todaysPrayers.Imsak}
                  </Text>
                </View>
              </View>

              <View style={styles.prayerTimeItem}>
                <View
                  style={[
                    styles.prayerTimeCard,
                    { backgroundColor: isDark ? '#333' : '#fff' },
                  ]}
                >
                  <Ionicons
                    name="partly-sunny-outline"
                    size={24}
                    color={isDark ? '#fff' : '#000'}
                  />
                  <Text
                    style={[
                      styles.prayerName,
                      { color: isDark ? '#fff' : '#000' },
                    ]}
                  >
                    Güneş
                  </Text>
                  <Text
                    style={[
                      styles.prayerTime,
                      { color: isDark ? '#fff' : '#000' },
                    ]}
                  >
                    {todaysPrayers.Gunes}
                  </Text>
                </View>
              </View>

              <View style={styles.prayerTimeItem}>
                <View
                  style={[
                    styles.prayerTimeCard,
                    { backgroundColor: isDark ? '#333' : '#fff' },
                  ]}
                >
                  <Ionicons
                    name="sunny"
                    size={24}
                    color={isDark ? '#fff' : '#000'}
                  />
                  <Text
                    style={[
                      styles.prayerName,
                      { color: isDark ? '#fff' : '#000' },
                    ]}
                  >
                    Öğle
                  </Text>
                  <Text
                    style={[
                      styles.prayerTime,
                      { color: isDark ? '#fff' : '#000' },
                    ]}
                  >
                    {todaysPrayers.Ogle}
                  </Text>
                </View>
              </View>

              <View style={styles.prayerTimeItem}>
                <View
                  style={[
                    styles.prayerTimeCard,
                    { backgroundColor: isDark ? '#333' : '#fff' },
                  ]}
                >
                  <Ionicons
                    name="partly-sunny"
                    size={24}
                    color={isDark ? '#fff' : '#000'}
                  />
                  <Text
                    style={[
                      styles.prayerName,
                      { color: isDark ? '#fff' : '#000' },
                    ]}
                  >
                    İkindi
                  </Text>
                  <Text
                    style={[
                      styles.prayerTime,
                      { color: isDark ? '#fff' : '#000' },
                    ]}
                  >
                    {todaysPrayers.Ikindi}
                  </Text>
                </View>
              </View>

              <View style={styles.prayerTimeItem}>
                <View
                  style={[
                    styles.prayerTimeCard,
                    { backgroundColor: isDark ? '#333' : '#fff' },
                  ]}
                >
                  <Ionicons
                    name="cloudy-night-outline"
                    size={24}
                    color={isDark ? '#fff' : '#000'}
                  />
                  <Text
                    style={[
                      styles.prayerName,
                      { color: isDark ? '#fff' : '#000' },
                    ]}
                  >
                    Akşam
                  </Text>
                  <Text
                    style={[
                      styles.prayerTime,
                      { color: isDark ? '#fff' : '#000' },
                    ]}
                  >
                    {todaysPrayers.Aksam}
                  </Text>
                </View>
              </View>

              <View style={styles.prayerTimeItem}>
                <View
                  style={[
                    styles.prayerTimeCard,
                    { backgroundColor: isDark ? '#333' : '#fff' },
                  ]}
                >
                  <Ionicons
                    name="moon-outline"
                    size={24}
                    color={isDark ? '#fff' : '#000'}
                  />
                  <Text
                    style={[
                      styles.prayerName,
                      { color: isDark ? '#fff' : '#000' },
                    ]}
                  >
                    Yatsı
                  </Text>
                  <Text
                    style={[
                      styles.prayerTime,
                      { color: isDark ? '#fff' : '#000' },
                    ]}
                  >
                    {todaysPrayers.Yatsi}
                  </Text>
                </View>
              </View>
            </View>
          </View>
        ) : null}
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
    justifyContent: 'space-between',
  },
  headerTitle: {
    fontSize: 32,
    fontWeight: 'bold',
  },
  settingsButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
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
  centered: {
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 200,
  },
  locationHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  flag: {
    fontSize: 24,
    marginRight: 12,
  },
  locationTitle: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  locationSubtitle: {
    fontSize: 14,
    marginTop: 2,
  },
  errorText: {
    fontSize: 16,
    textAlign: 'center',
  },
  prayerHeader: {
    marginBottom: 20,
  },
  prayerDate: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 4,
  },
  hijriDate: {
    fontSize: 14,
  },
  prayerTimesGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
  prayerTimeItem: {
    width: '48%',
    marginBottom: 12,
  },
  prayerTimeCard: {
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  prayerName: {
    fontSize: 16,
    fontWeight: '500',
    marginTop: 8,
  },
  prayerTime: {
    fontSize: 20,
    fontWeight: 'bold',
    marginTop: 4,
  },
});
